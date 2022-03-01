module Unleash
  module ConstraintMatcher
    class StringConstraint
      def self.matches?(operator, context_value, constraint_value, case_insensitive = false)
        if case_insensitive
          constraint_value = constraint_value.map(&:upcase)
          context_value = context_value.upcase
        end
        case operator
        when "STR_STARTS_WITH"
          constraint_value.any?{ |value| context_value.start_with? value }
        when "STR_ENDS_WITH"
          constraint_value.any?{ |value| context_value.end_with? value }
        when "STR_CONTAINS"
          constraint_value.any?{ |value| context_value.include? value }
        end
      end
    end
  end
end
