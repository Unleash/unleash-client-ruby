module Unleash
  class Metrics
    attr_accessor :features, :features_lock

    def initialize
      self.features = {}
      self.features_lock = Mutex.new
    end

    def to_s
      self.features_lock.synchronize do
        return self.features.to_json
      end
    end

    def increment(feature, choice)
      raise "InvalidArgument choice must be :yes or :no" unless [:yes, :no].include? choice

      self.features_lock.synchronize do
        self.features[feature] = { yes: 0, no: 0 } unless self.features.include? feature
        self.features[feature][choice] += 1
      end
    end

    def increment_variant(feature, variant)
      self.features_lock.synchronize do
        self.features[feature] = { yes: 0, no: 0 } unless self.features.include? feature
        self.features[feature]['variant'] = {}     unless self.features[feature].include? 'variant'
        self.features[feature]['variant'][variant] = 0 unless self.features[feature]['variant'].include? variant
        self.features[feature]['variant'][variant] += 1
      end
    end

    def reset
      self.features_lock.synchronize do
        self.features = {}
      end
    end
  end
end
