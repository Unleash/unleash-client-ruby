module Unleash
  module Strategy
    class NotImplemented < RuntimeError
    end

    class Base
      def name
        raise NotImplemented, "Strategy is not implemented"
      end

      def is_enabled?(_params = {}, _context = nil)
        raise NotImplemented, "Strategy is not implemented"
      end
    end
  end
end
