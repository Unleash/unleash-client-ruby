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

      feature_matrix = self.features[feature] || { yes: 0, no: 0 }
      feature_matrix[choice] += 1

      self.features[feature] = feature_matrix
    end

    def increment_variant(feature, variant)
      feature_matrix = self.features[feature] || { yes: 0, no: 0 }
      feature_matrix['variant'] ||= {}
      feature_matrix['variant'][variant] ||= 0
      feature_matrix['variant'][variant] += 1

      self.features[feature] = feature_matrix
    end

    def reset
      self.features = {}
    end
  end
end
