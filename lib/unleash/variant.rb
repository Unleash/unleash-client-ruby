module Unleash
  class Variant
    attr_accessor :name, :enabled, :payload, :feature_enabled

    def initialize(params = {})
      raise ArgumentError, "Variant initializer requires a hash." unless params.is_a?(Hash)

      self.name = params.values_at('name', :name).compact.first
      self.enabled = params.values_at('enabled', :enabled).compact.first || false
      self.payload = params.values_at('payload', :payload).compact.first
      self.feature_enabled = params.values_at('feature_enabled', :feature_enabled).compact.first || false

      raise ArgumentError, "Variant requires a name." if self.name.nil?
    end

    def to_s
      # :nocov:
      "<Variant: name=#{self.name},enabled=#{self.enabled},payload=#{self.payload},feature_enabled=#{self.feature_enabled}>"
      # :nocov:
    end

    def ==(other)
      self.name == other.name && self.enabled == other.enabled && self.payload == other.payload \
        && self.feature_enabled == other.feature_enabled
    end

    def self.disabled_variant
      Variant.new(name: 'disabled', enabled: false, feature_enabled: false)
    end
  end
end
