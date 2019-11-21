require 'unleash/strategy/util'

module Unleash
  module Strategy
    class GradualRolloutRandom < Base
      def name
        'gradualRolloutRandom'
      end

      # need: params['percentage']
      def is_enabled?(params = {}, _context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('percentage')

        begin
          percentage = Integer(params['percentage'] || 0)
        rescue ArgumentError
          return false
        end

        (percentage >= Random.rand(1..100))
      end
    end
  end
end
