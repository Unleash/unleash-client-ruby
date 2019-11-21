require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutSessionId < Base
      def name
        'gradualRolloutSessionId'
      end

      # need: params['percentage'], params['groupId'], context.user_id,
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('percentage')
        return false unless context.class.name == 'Unleash::Context'
        return false if context.session_id.empty?

        percentage = Integer(params['percentage'] || 0)
        (percentage.positive? && Util.get_normalized_number(context.session_id, params['groupId'] || "") <= percentage)
      end
    end
  end
end
