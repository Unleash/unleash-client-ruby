require 'date'

module Unleash
  class Constraint
    attr_accessor :context_name, :operator, :value, :inverted, :case_insensitive

    CONTAINS_OPERATORS = [
      'IN',
      'NOT_IN'
    ].freeze

    STRING_OPERATORS = [
      'STR_STARTS_WITH',
      'STR_ENDS_WITH',
      'STR_CONTAINS'
    ].freeze

    NUMERIC_OPERATORS = [
      'NUM_EQ',
      'NUM_GT',
      'NUM_GTE',
      'NUM_LT',
      'NUM_LTE'
    ].freeze

    DATE_OPERATORS = [
      'DATE_AFTER',
      'DATE_BEFORE'
    ].freeze

    SEMVER_OPERATORS = [
      'SEMVER_EQ',
      'SEMVER_GT',
      'SEMVER_LT'
    ].freeze

    VALID_OPERATORS = [
      CONTAINS_OPERATORS,
      STRING_OPERATORS,
      NUMERIC_OPERATORS,
      DATE_OPERATORS,
      SEMVER_OPERATORS
    ].flatten.freeze

    def initialize(context_name, operator, value = [], inverted = false, case_insensitive = false)
      raise ArgumentError, "context_name is not a String" unless context_name.is_a?(String)
      raise ArgumentError, "operator does not hold a valid value:" + VALID_OPERATORS unless VALID_OPERATORS.include? operator
      raise ArgumentError, "value must either hold an array or a single string" unless value.is_a?(Array) || value.is_a?(String)

      self.context_name = context_name
      self.operator = operator
      self.value = value
      self.inverted = inverted
      self.case_insensitive = case_insensitive
    end

    def matches_context?(context)
      Unleash.logger.debug "Unleash::Constraint matches_context? value: #{self.value} context.get_by_name(#{self.context_name})" \
        " #{context.get_by_name(self.context_name)} "
      match = matches_constraint?(context)
      self.inverted ? !match : match
    end

    private

    def matches_constraint?(context)
      if CONTAINS_OPERATORS.include? self.operator
        matches_contains_operator?(context)
      elsif STRING_OPERATORS.include? self.operator
        matches_string_operator?(context)
      elsif NUMERIC_OPERATORS.include? self.operator
        matches_numeric_operator?(context)
      elsif DATE_OPERATORS.include? self.operator
        matches_date_operator?(context)
      elsif SEMVER_OPERATORS.include? self.operator
        matches_semver_operator?(context)
      else
        Unleash.logger.warn "Invalid constraint operator: #{self.operator}, this should be unreachable. Defaulting to false"
        false
      end
    end

    def matches_contains_operator?(context)
      is_included = self.value.include? context.get_by_name(self.context_name)
      operator == 'IN' ? is_included : !is_included
    end

    def matches_string_operator?(context)
      context_value = context.get_by_name(self.context_name)
      constraint_value = self.value
      if self.case_insensitive
        constraint_value = constraint_value.map(&:upcase)
        context_value = context_value.upcase
      end
      case self.operator
      when "STR_STARTS_WITH"
        constraint_value.any?{ |value| context_value.start_with? value }
      when "STR_ENDS_WITH"
        constraint_value.any?{ |value| context_value.end_with? value }
      when "STR_CONTAINS"
        constraint_value.any?{ |value| context_value.include? value }
      end
    end

    def matches_numeric_operator?(context)
      begin
        context_value = Float(context.get_by_name(self.context_name))
        constraint_value = Float(self.value)
      rescue ArgumentError
        false
      end

      case self.operator
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

    def matches_date_operator?(context)
      begin
        context_value = DateTime.parse(context.get_by_name(self.context_name))
        constraint_value = DateTime.parse(self.value)
      rescue ArgumentError
        false
      end
      case self.operator
      when "DATE_AFTER"
        constraint_value < context_value
      when "DATE_BEFORE"
        constraint_value > context_value
      end
    end

    def matches_semver_operator?(context)
      begin
        context_value = Gem::Version.new(context.get_by_name(self.context_name))
        constraint_value = Gem::Version.new(self.value)
      rescue ArgumentError
        false
      end

      case self.operator
      when "SEMVER_EQ"
        constraint_value == context_value
      when "SEMVER_GT"
        constraint_value < context_value
      when "SEMVER_LT"
        constraint_value > context_value
      end
    end
  end
end
