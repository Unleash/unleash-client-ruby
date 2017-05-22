require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutUserId < Base
      def name
        'gradualRolloutUserId'
      end

      # need: :user_id, :percentage
      def is_enabled?(params = {})
        return false if params.nil? || params.size == 0
        percentage = Integer(params[:percentage] || 0)

        ( percentage > 0 && get_normalized_number(params[:identifier], params[:user_id]) <= percentage )
      end
    end
  end
end
