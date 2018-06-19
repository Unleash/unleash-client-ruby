require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutRandom < Base
      def name
        'gradualRolloutRandom'
      end

      # need: params['percentage']
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('percentage')

        begin
          percentage = Integer(params['percentage'] || 0)
        rescue ArgumentError => e
          return false
        end

        randomNumber = Random.rand(100) + 1

        ( percentage >= randomNumber )
      end
    end
  end
end
