module Unleash
  class ActivationStrategy
    attr_accessor :name, :params, :constraints, :disabled, :variants

    def initialize(name, params, constraints = [], variants = [])
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

      if constraints.is_a?(Array) && constraints.each{ |c| c.is_a?(Constraint) }
        self.constraints = constraints
      else
        Unleash.logger.warn "Invalid constraints provided for ActivationStrategy (constraints: #{constraints})"
        self.disabled = true
        self.constraints = []
      end

      self.variants = valid_variants(variants)
    end

    def matches_context?(context)
      self.constraints.any?{ |c| c.matches_context? context }
    end

    private

    def valid_variants(variants)
      if variants.is_a?(Array) && variants.each{ |variant| variant.is_a?(VariantDefinition) }
        variants
      else
        Unleash.logger.warn "Invalid variants provided for ActivationStrategy (variants: #{variants})"
        []
      end
    end
  end
end
