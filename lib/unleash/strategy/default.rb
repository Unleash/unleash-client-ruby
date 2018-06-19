module Unleash
  module Strategy
    class Default < Base
      def name
        'default'
      end

      def is_enabled?(params = {}, context = nil)
        true
      end
    end
  end
end
