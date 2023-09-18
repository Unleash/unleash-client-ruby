require 'unleash/variant_definition'
require 'unleash/variant'

module Unleash
  class FeatureToggle
    def self.disabled_variant
      Unleash::Variant.new(name: 'disabled', enabled: false)
    end
  end
end
