require 'murmurhash3'

module Unleash
  module Strategy
    module Util
      module_function

      NORMALIZER = 100

      # convert the two strings () into a number between 1 and 100
      def get_normalized_number(identifier, group_id)
        MurmurHash3::V32.str_hash("#{group_id}:#{identifier}") % NORMALIZER + 1
      end
    end
  end
end