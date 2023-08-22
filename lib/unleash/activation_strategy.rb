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

      if constraints.is_a?(Array) && constraints.each { |c| c.is_a?(Constraint) }
        self.constraints = constraints
      else
        Unleash.logger.warn "Invalid constraints provided for ActivationStrategy (contraints: #{constraints})"
        self.disabled = true
        self.constraints = []
      end

      if variants.is_a?(Array)
        self.variants = variants
          .select { |v| v.is_a?(Hash) && v.has_key?("name") }
          .map { |v|
          VariantDefinition.new(
            v.fetch("name", ""),
            v.fetch("weight", 0),
            v.fetch("payload", nil),
            v.fetch("stickiness", nil),
            v.fetch("overrides", [])
          )
        }
      end
    end

    def matches_context?(context)
      self.constraints.any? { |c| c.matches_context? context }
    end
  end
end
