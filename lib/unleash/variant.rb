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

    def ==(other)
      self.name == other.name && self.enabled == other.enabled && self.payload == other.payload
    end
  end
end
