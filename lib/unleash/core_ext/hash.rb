module Unleash
  module CoreExtensions
    module Hash
      def transform_keys
        result = {}
        each_key do |key|
          result[yield(key)] = self[key]
        end
        result
      end
    end
  end
end
