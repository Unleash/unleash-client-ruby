module Unleash
  module ConstraintMatcher
    class NumericConstraint
      OPERATORS = [
        'NUM_EQ',
        'NUM_GT',
        'NUM_GTE',
        'NUM_LT',
        'NUM_LTE'
      ].freeze

      def self.matches?(operator, context_value, constraint_value)
        begin
          context_value = Float(context_value)
          constraint_value = Float(constraint_value)
        rescue ArgumentError
          false
        end

        case operator
        when "NUM_EQ"
          (constraint_value - context_value).abs < 0.001
        when "NUM_LT"
          constraint_value > context_value
        when "NUM_LTE"
          constraint_value >= context_value
        when "NUM_GT"
          constraint_value < context_value
        when "NUM_GTE"
          constraint_value <= context_value
        end
      end

      def self.include?(operator)
        OPERATORS.include? operator
      end
    end
  end
end
