module Unleash
  module Strategy
    class Base
      def name
        raise NotImplemented, "Strategy is not implemented"
      end

      def is_enabled?(params = {})
        raise NotImplemented, "Strategy is not implemented"
      end
    end
  end
end
