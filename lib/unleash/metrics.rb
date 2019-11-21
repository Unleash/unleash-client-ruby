module Unleash
  class Metrics
    attr_accessor :features

    # NOTE: no mutexes for features

    def initialize
      self.features = {}
    end

    def to_s
      self.features.to_json
    end

    def increment(feature, choice)
      raise "InvalidArgument choice must be :yes or :no" unless [:yes, :no].include? choice

      self.features[feature] = { yes: 0, no: 0 } unless self.features.include? feature
      self.features[feature][choice] += 1
    end

    def increment_variant(feature, variant)
      self.features[feature] = { yes: 0, no: 0 } unless self.features.include? feature
      self.features[feature]['variant'] = {}     unless self.features[feature].include? 'variant'
      self.features[feature]['variant'][variant] = 0 unless self.features[feature]['variant'].include? variant
      self.features[feature]['variant'][variant] += 1
    end

    def reset
      self.features = {}
    end
  end
end
