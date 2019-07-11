

module Unleash
  class Variant
    attr_accessor :name, :enabled, :payload

    def initialize(params = {})
      raise ArgumentError, "Variant initializer requires a hash." unless params.is_a?(Hash)

      self.name = params.values_at('name', :name).compact.first
      self.enabled = params.values_at('enabled', :enabled).compact.first || false
      self.payload = params.values_at('payload', :payload).compact.first

      raise ArgumentError, "Variant requires a name." if self.name.nil?
    end

    def to_s
      "<Variant: name=#{self.name},enabled=#{self.enabled},payload=#{self.payload}>"
    end

    def ==(v)
      self.name == v.name && self.enabled == v.enabled && self.payload == v.payload
    end

  end
end
