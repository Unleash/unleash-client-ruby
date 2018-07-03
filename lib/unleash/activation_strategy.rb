

module Unleash
  class ActivationStrategy
    attr_accessor :name, :params

    def initialize(name, params = {})
      self.name = name
      if params.is_a?(Hash)
        self.params = params
      else
        Unleash.logger.warn "Invalid params provided for ActivationStrategy #{params}"
        self.params = {}
      end
    end
  end
end
