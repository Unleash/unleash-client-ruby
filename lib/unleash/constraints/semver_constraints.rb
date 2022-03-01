module Unleash
  module ConstraintMatcher
    class SemverConstraint
      OPERATORS = [
        'SEMVER_EQ',
        'SEMVER_GT',
        'SEMVER_LT'
      ].freeze

      def self.matches?(operator, context_value, constraint_value)
        begin
          context_value = Gem::Version.new(context_value)
          constraint_value = Gem::Version.new(constraint_value)
        rescue ArgumentError
          false
        end

        case operator
        when "SEMVER_EQ"
          constraint_value == context_value
        when "SEMVER_GT"
          constraint_value < context_value
        when "SEMVER_LT"
          constraint_value > context_value
        end
      end

      def self.include?(operator)
        OPERATORS.include? operator
      end
    end
  end
end
