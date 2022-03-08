require 'date'

module Unleash
  class Constraint
    attr_accessor :context_name, :operator, :value, :inverted, :case_insensitive

    OPERATORS = {
      IN: ->(context_value, constraint_value){ constraint_value.include? context_value },
      NOT_IN: ->(context_value, constraint_value){ !constraint_value.include? context_value },
      STR_STARTS_WITH: ->(context_value, constraint_value){ constraint_value.any?{ |v| context_value.start_with? v } },
      STR_ENDS_WITH: ->(context_value, constraint_value){ constraint_value.any?{ |v| context_value.end_with? v } },
      STR_CONTAINS: ->(context_value, constraint_value){ constraint_value.any?{ |v| context_value.include? v } },
      NUM_EQ: ->(context_value, constraint_value){ on_valid_float(constraint_value, context_value){ |x, y| (x - y).abs < Float::EPSILON } },
      NUM_LT: ->(context_value, constraint_value){ on_valid_float(constraint_value, context_value){ |x, y| (x > y) } },
      NUM_LTE: ->(context_value, constraint_value){ on_valid_float(constraint_value, context_value){ |x, y| (x >= y) } },
      NUM_GT: ->(context_value, constraint_value){ on_valid_float(constraint_value, context_value){ |x, y| (x < y) } },
      NUM_GTE: ->(context_value, constraint_value){ on_valid_float(constraint_value, context_value){ |x, y| (x <= y) } },
      DATE_AFTER: ->(context_value, constraint_value){ on_valid_date(constraint_value, context_value){ |x, y| (x < y) } },
      DATE_BEFORE: ->(context_value, constraint_value){ on_valid_date(constraint_value, context_value){ |x, y| (x > y) } },
      SEMVER_EQ: ->(context_value, constraint_value){ on_valid_version(constraint_value, context_value){ |x, y| (x == y) } },
      SEMVER_GT: ->(context_value, constraint_value){ on_valid_version(constraint_value, context_value){ |x, y| (x < y) } },
      SEMVER_LT: ->(context_value, constraint_value){ on_valid_version(constraint_value, context_value){ |x, y| (x > y) } }
    }.freeze

    VALID_LIST_TYPES = ["IN", "NOT_IN", "STR_STARTS_WITH", "STR_ENDS_WITH", "STR_CONTAINS"].map(&:to_sym).freeze

    def initialize(context_name, operator, value = [], inverted: false, case_insensitive: false)
      raise ArgumentError, "context_name is not a String" unless context_name.is_a?(String)
      raise ArgumentError, "operator does not hold a valid value:" + OPERATORS.keys unless OPERATORS.include? operator.to_sym

      self.validate_constraint_value_type(operator.to_sym, value)

      self.context_name = context_name
      self.operator = operator.to_sym
      self.value = value
      self.inverted = !!inverted
      self.case_insensitive = !!case_insensitive
    end

    def matches_context?(context)
      Unleash.logger.debug "Unleash::Constraint matches_context? value: #{self.value} context.get_by_name(#{self.context_name})" \
        " #{context.get_by_name(self.context_name)} "
      match = matches_constraint?(context)
      puts "CHECKING A CONSTRAIT #{match}, #{self.operator}, #{context}"
      self.inverted ? !match : match
    rescue KeyError
      Unleash.logger.debug "Attemped to resolve a context key during constraint resolution: #{self.context_name} but it wasn't \
      found on the context"
      false
    end

    def self.on_valid_date(val1, val2)
      val1 = DateTime.parse(val1)
      val2 = DateTime.parse(val2)
      yield(val1, val2)
    rescue ArgumentError
      Unleash.logger.warn "Unleash::ConstraintMatcher unable to parse either context_value (#{val1}) \
      or constraint_value (#{val2}) into a date. This will always return false."
      false
    end

    def self.on_valid_float(val1, val2)
      val1 = Float(val1)
      val2 = Float(val2)
      yield(val1, val2)
    rescue ArgumentError
      Unleash.logger.warn "Unleash::ConstraintMatcher unable to parse either context_value (#{val1}) \
      or constraint_value (#{val2}) into a number. This will always return false."
      false
    end

    def self.on_valid_version(val1, val2)
      val1 = Gem::Version.new(val1)
      val2 = Gem::Version.new(val2)
      yield(val1, val2)
    rescue ArgumentError
      Unleash.logger.warn "Unleash::ConstraintMatcher unable to parse either context_value (#{val1}) \
      or constraint_value (#{val2}) into a version. This will always return false."
      false
    end

    # This should be a private method but for some reason this fails on Ruby 2.5
    def validate_constraint_value_type(operator, value)
      raise ArgumentError, "context_name is not an Array" if VALID_LIST_TYPES.include?(operator) && value.is_a?(String)
      raise ArgumentError, "context_name is not a String" if !VALID_LIST_TYPES.include?(operator) && value.is_a?(Array)
    end

    private

    def matches_constraint?(context)
      unless OPERATORS.include?(self.operator)
        Unleash.logger.warn "Invalid constraint operator: #{self.operator}, this should be unreachable. Always returning false."
        false
      end

      v = self.value.dup
      context_value = context.get_by_name(self.context_name)

      v.map!(&:upcase) if self.case_insensitive
      context_value.upcase! if self.case_insensitive

      OPERATORS[self.operator].call(context_value, v)
    end
  end
end
