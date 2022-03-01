module Unleash
  module ConstraintMatcher
    class DateConstraint
      OPERATORS = [
        'DATE_AFTER',
        'DATE_BEFORE'
      ].freeze

      def self.matches?(operator, context_value, constraint_value)
        begin
          context_value = DateTime.parse(context_value)
          constraint_value = DateTime.parse(constraint_value)
        rescue ArgumentError
          false
        end

        case operator
        when "DATE_AFTER"
          constraint_value < context_value
        when "DATE_BEFORE"
          constraint_value > context_value
        end
      end

      def self.include?(operator)
        OPERATORS.include? operator
      end
    end
  end
end
