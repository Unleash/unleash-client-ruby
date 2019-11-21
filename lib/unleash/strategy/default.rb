module Unleash
  module Strategy
    class Default < Base
      def name
        'default'
      end

      def is_enabled?(_params = {}, _context = nil)
        true
      end
    end
  end
end
