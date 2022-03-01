module Unleash
  module ConstraintMatcher
    class ContainsConstraint
      OPERATORS = [
        'IN',
        'NOT_IN'
      ].freeze

      def self.matches?(operator, context_value, constraint_value)
        is_included = constraint_value.include? context_value
        operator == 'IN' ? is_included : !is_included
      end

      def self.include?(operator)
        OPERATORS.include? operator
      end
    end
  end
end
