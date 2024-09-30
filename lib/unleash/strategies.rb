module Unleash
  class DefaultOverrideError < RuntimeError
  end

  class Strategies
    attr_accessor :strategies

    def initialize
      @strategies = {}
    end

    def includes?(name)
      @strategies.has_key?(name.to_s) || DEFAULT_STRATEGIES.include?(name.to_s)
    end

    def add(strategy)
      raise DefaultOverrideError, "Cannot override a default strategy" if DEFAULT_STRATEGIES.include?(strategy.name)

      @strategies[strategy.name] = strategy
    end

    def custom_strategies
      @strategies.values
    end

    def known_strategies
      @strategies.keys.map{ |key| { name: key } }
    end

    DEFAULT_STRATEGIES = ['applicationHostname', 'default', 'flexibleRollout', 'gradualRolloutRandom', 'gradualRolloutSessionId',
                          'gradualRolloutUserId', 'remoteAddress', 'userWithId'].freeze
  end
end
