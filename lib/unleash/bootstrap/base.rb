module Unleash
  module Bootstrap
    class NotImplemented < RuntimeError
    end

    class Base
      def read
        raise NotImplemented, "Bootstrap is not implemented"
      end

      def extract_features(bootstrap_hash)
        raise NotImplemented, "The provided bootstrap data doesn't seem to have a valid set of toggles" if bootstrap_hash['version'] < 1

        bootstrap_hash['features']
      end
    end
  end
end
