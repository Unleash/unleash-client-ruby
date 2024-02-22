require 'unleash/strategy/util'

module Unleash
  module Strategy
    class FlexibleRollout < Base
      def name
        'flexibleRollout'
      end

      # need: params['percentage']
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash)

        stickiness = params.fetch('stickiness', 'default')
        return false if context_invalid?(stickiness, context)

        stickiness_id = resolve_stickiness(stickiness, context)

        begin
          percentage = Integer(params.fetch('rollout', 0))
          percentage = 0 if percentage > 100 || percentage.negative?
        rescue ArgumentError
          return false
        end

        group_id = params.fetch('groupId', '')
        normalized_number = Util.get_normalized_number(stickiness_id, group_id, 0)

        return false if stickiness_id.nil?

        (percentage.positive? && normalized_number <= percentage)
      end

      private

      def context_invalid?(stickiness, context)
        return false if ['random', 'default'].include?(stickiness)

        !context.instance_of?(Unleash::Context)
      end

      def random
        Random.rand(0..100)
      end

      def resolve_stickiness(stickiness, context)
        case stickiness
        when 'random'
          random
        when 'default'
          return random unless context.instance_of?(Unleash::Context)

          context&.user_id || context&.session_id || random
        else
          begin
            context.get_by_name(stickiness)
          rescue KeyError
            nil
          end
        end
      end
    end
  end
end
