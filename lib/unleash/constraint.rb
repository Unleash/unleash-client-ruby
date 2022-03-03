require 'date'
require 'unleash/constraints/contains_constraints'
require 'unleash/constraints/date_constraints'
require 'unleash/constraints/numeric_constraints'
require 'unleash/constraints/semver_constraints'
require 'unleash/constraints/string_constraints'

module Unleash
  class Constraint
    attr_accessor :context_name, :operator, :value, :inverted, :case_insensitive

    VALID_OPERATORS = [
      ConstraintMatcher::ContainsConstraint::OPERATORS,
      ConstraintMatcher::StringConstraint::OPERATORS,
      ConstraintMatcher::NumericConstraint::OPERATORS,
      ConstraintMatcher::DateConstraint::OPERATORS,
      ConstraintMatcher::SemverConstraint::OPERATORS
    ].flatten.freeze

    def initialize(context_name, operator, value = [], inverted: false, case_insensitive: false)
      raise ArgumentError, "context_name is not a String" unless context_name.is_a?(String)
      raise ArgumentError, "operator does not hold a valid value:" + VALID_OPERATORS unless VALID_OPERATORS.include? operator
      raise ArgumentError, "value must either hold an array or a single string" unless value.is_a?(Array) || value.is_a?(String)

      self.context_name = context_name
      self.operator = operator
      self.value = value
      self.inverted = !!inverted
      self.case_insensitive = !!case_insensitive
    end

    def matches_context?(context)
      Unleash.logger.debug "Unleash::Constraint matches_context? value: #{self.value} context.get_by_name(#{self.context_name})" \
        " #{context.get_by_name(self.context_name)} "
      match = matches_constraint?(context)
      self.inverted ? !match : match
    end

    private

    # rubocop:disable Metrics/AbcSize
    def matches_constraint?(context)
      context_value = context.get_by_name(self.context_name)

      if ConstraintMatcher::ContainsConstraint.include? self.operator
        ConstraintMatcher::ContainsConstraint.matches?(self.operator, context_value, self.value)
      elsif ConstraintMatcher::StringConstraint.include? self.operator
        ConstraintMatcher::StringConstraint.matches?(self.operator, context_value, self.value, case_insensitive: self.case_insensitive)
      elsif ConstraintMatcher::NumericConstraint.include? self.operator
        ConstraintMatcher::NumericConstraint.matches?(self.operator, context_value, self.value)
      elsif ConstraintMatcher::DateConstraint.include? self.operator
        ConstraintMatcher::DateConstraint.matches?(self.operator, context_value, self.value)
      elsif ConstraintMatcher::SemverConstraint.include? self.operator
        ConstraintMatcher::SemverConstraint.matches?(self.operator, context_value, self.value)
      else
        Unleash.logger.warn "Invalid constraint operator: #{self.operator}, this should be unreachable. Defaulting to false"
        false
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
