module Unleash
  class ActivationStrategy
    attr_accessor :name, :params, :constraints

    def initialize(name, params, constraints = [])
      self.name = name

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
        Unleash.logger.warn "Invalid constraints provided for ActivationStrategy (contraints: #{constraints})"
        self.constraints = []
      end
    end

    def matches_context?(context)
      self.constraints.any?{ |c| c.matches_context? context }
    end
  end
end
