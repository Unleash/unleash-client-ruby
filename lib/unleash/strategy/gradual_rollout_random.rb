require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutRandom < Base
      def name
        'gradualRolloutRandom'
      end

      # need: :percentage
      def is_enabled?(params = {})
        return false if params.nil? || params.size == 0
        percentage = Integer(params[:percentage] || 0)

        randomNumber = Random.rand(100) + 1

        ( percentage >= randomNumber )
      end
    end
  end
end
