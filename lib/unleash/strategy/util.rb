require 'murmurhash3'

module Unleash
  module Strategy
    module Util
      module_function

      NORMALIZER = 100

      # convert the two strings () into a number between 1 and base (100 by default)
      def get_normalized_number(identifier, group_id, base = NORMALIZER)
        MurmurHash3::V32.str_hash("#{group_id}:#{identifier}") % base + 1
      end
    end
  end
end
