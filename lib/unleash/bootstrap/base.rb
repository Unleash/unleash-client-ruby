module Unleash
  module Bootstrap
    class NotImplemented < RuntimeError
    end

    class Base
      def read
        raise NotImplemented, "Bootstrap is not implemented"
      end
    end
  end
end
