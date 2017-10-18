module Unleash
  module Strategy
    class Unknown < Base
      def name
        'unknown'
      end

      def is_enabled?(params = {})
        false
      end
    end
  end
end
