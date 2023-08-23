module Unleash
  class ActivationStrategy
    attr_accessor :name, :params, :constraints, :disabled, :variant_definitions

    def initialize(name, params, constraints = [], variant_definitions = [])
      self.name = name
      self.disabled = false

      if params.is_a?(Hash)
        self.params = params
      elsif params.nil?
        self.params = {}
      else
        Unleash.logger.warn "Invalid params provided for ActivationStrategy (params:#{params})"
        self.params = {}
      end

      if constraints.is_a?(Array) && constraints.all?{ |c| c.is_a?(Constraint) }
        self.constraints = constraints
      else
        Unleash.logger.warn "Invalid constraints provided for ActivationStrategy (constraints: #{constraints})"
        self.disabled = true
        self.constraints = []
      end

      self.variant_definitions = valid_variant_definitions(variant_definitions)
    end

    def matches_context?(context)
      self.constraints.any?{ |c| c.matches_context? context }
    end

    private

    def valid_variant_definitions(variant_definitions)
      if variant_definitions.is_a?(Array) && variant_definitions.all?{ |variant_definition| variant_definition.is_a?(VariantDefinition) }
        variant_definitions
      else
        Unleash.logger.warn "Invalid variant_definitions provided for ActivationStrategy (variant_definitions: #{variant_definitions})"
        []
      end
    end
  end
end
