module Unleash
  module Strategy
    module Util
      module_function

      TWO_31 = 2 ** 31
      TWO_32 = 2 ** 32


      def get_normalized_number(identifier, group_id)
        java_hash_code("#{identifier}:#{group_id}") % 100 + 1
      end


      # This returns same result as java hashCode() does
      def java_hash_code(str)
        size = str.size
        hash = 0
        str.chars.each_with_index do |ch, i|
          hash += ch.ord * (31 ** (size-(i+1)))
          hash = hash % TWO_32 - TWO_31
        end
        hash
      end
    end
  end
end