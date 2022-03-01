module Unleash
  module ConstraintMatcher
    class NumericConstraint
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
    end
  end
end
