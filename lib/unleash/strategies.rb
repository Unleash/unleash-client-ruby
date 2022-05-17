require 'unleash/strategy/base'
Gem.find_files('unleash/strategy/**/*.rb').each{ |path| require path }

module Unleash
  class Strategies
    def initialize
      @strategies = {}
      DEFAULT_STRATEGIES.each{ |strategy_class| add(strategy_class.new) }
    end

    def keys
      @strategies.keys
    end

    def includes?(name)
      @strategies.has_key?(name.to_s)
    end

    def fetch(name)
      raise Unleash::Strategy::NotImplemented, "Strategy is not implemented" unless (strategy = @strategies[name.to_s])

      strategy
    end

    def add(strategy)
      @strategies[strategy.name] = strategy
    end

    def []=(key, strategy)
      @strategies[key.to_s] = strategy
    end

    def [](key)
      @strategies[key.to_s]
    end

    DEFAULT_STRATEGIES = [
      Unleash::Strategy::ApplicationHostname,
      Unleash::Strategy::Default,
      Unleash::Strategy::FlexibleRollout,
      Unleash::Strategy::GradualRolloutRandom,
      Unleash::Strategy::GradualRolloutSessionId,
      Unleash::Strategy::GradualRolloutUserId,
      Unleash::Strategy::RemoteAddress,
      Unleash::Strategy::UserWithId
    ].freeze
  end
end
