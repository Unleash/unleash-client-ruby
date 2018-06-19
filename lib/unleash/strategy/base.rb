module Unleash
  module Strategy
    class NotImplemented < Exception
    end

    class Base
      def name
        raise NotImplemented, "Strategy is not implemented"
      end

      def is_enabled?(params = {}, context = nil)
        raise NotImplemented, "Strategy is not implemented"
      end
    end
  end
end
