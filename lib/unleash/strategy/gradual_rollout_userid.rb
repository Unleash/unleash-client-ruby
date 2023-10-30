require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutUserId < Base
      def name
        'gradualRolloutUserId'
      end

      # need: params['percentage'], params['groupId'], context.user_id,
      def is_enabled?(params = {}, context = nil, _constraints = [])
        return false unless params.is_a?(Hash) && params.has_key?('percentage')
        return false unless context.instance_of?(Unleash::Context)
        return false if context.user_id.nil? || context.user_id.empty?

        percentage = Integer(params['percentage'] || 0)
        (percentage.positive? && Util.get_normalized_number(context.user_id, params['groupId'] || "", 0) <= percentage)
      end
    end
  end
end
