require 'unleash/variant_override'

module Unleash
  class VariantDefinition
    attr_accessor :name, :weight, :payload, :overrides

    def initialize(name, weight = 0, payload = nil, overrides = [])
      self.name = name
      self.weight = weight
      self.payload = payload
      # self.overrides = overrides
      self.overrides = (overrides || [])
        .select{ |v| v.is_a?(Hash) && v.has_key?('contextName') }
        .map{ |v| VariantOverride.new(v.fetch('contextName', ''), v.fetch('values', [])) } || []
    end

    def override_matches_context?(context)
      self.overrides.select{ |o| o.matches_context?(context) }.first
    end

    def to_s
      "<VariantDefinition: name=#{self.name},weight=#{self.weight},payload=#{self.payload},overrides=#{self.overrides}>"
    end
  end
end
