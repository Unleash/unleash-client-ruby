module Unleash
  module ConstraintMatcher
    class ContainsConstraint
      def self.matches?(operator, context_value, constraint_value)
        is_included = constraint_value.include? context_value
        operator == 'IN' ? is_included : !is_included
      end
    end
  end
end
