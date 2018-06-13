require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutUserId < Base
      def name
        'gradualRolloutUserId'
      end

      # need: params['percentage'], params['groupId'], context.user_id,
      def is_enabled?(params = {}, context)
        return false if params.nil? || params.size == 0
        return false if context.class.name != 'Unleash::Context'

        percentage = Integer(params['percentage'] || 0)
        ( percentage > 0 && Util.get_normalized_number(context.user_id, params['groupId'] || "") <= percentage )
      end
    end
  end
end
