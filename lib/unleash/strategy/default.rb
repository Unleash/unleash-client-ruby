module Unleash
  module Strategy
    class Default < Base
      def name
        'default'
      end

      def is_enabled?(params = {})
        true
      end
    end
  end
end
