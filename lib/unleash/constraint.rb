module Unleash
  class Constraint
    attr_accessor :context_name, :operator, :values

    VALID_OPERATORS = ['IN', 'NOT_IN'].freeze

    def initialize(context_name, operator, values = [])
      raise ArgumentError, "context_name is not a String" unless context_name.is_a?(String)
      raise ArgumentError, "operator does not hold a valid value:" + VALID_OPERATORS unless VALID_OPERATORS.include? operator
      raise ArgumentError, "values does not hold an Array" unless values.is_a?(Array)

      self.context_name = context_name
      self.operator = operator
      self.values = values
    end

    def matches_context?(context)
      Unleash.logger.debug "Unleash::Constraint matches_context? values: #{self.values} context.get_by_name(#{self.context_name})" \
        " #{context.get_by_name(self.context_name)} "

      is_included = self.values.include? context.get_by_name(self.context_name)

      operator == 'IN' ? is_included : !is_included
    end
  end
end
