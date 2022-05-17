require 'unleash/strategy/base'
Gem.find_files('unleash/strategy/**/*.rb').each{ |path| require path }

module Unleash
  class Strategies
    def initialize
      @strategies = {}
      register_strategies
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

    def register_strategies
      register_base_strategies
      register_custom_strategies
    end

    protected

    def register_custom_strategies
      Unleash::Strategy.constants
        .select{ |c| Unleash::Strategy.const_get(c).is_a? Class }
        .reject{ |c| ['NotImplemented', 'Base'].include?(c.to_s) } # Reject abstract classes
        .map{ |c| Object.const_get("Unleash::Strategy::#{c}") }
        .reject{ |c| DEFAULT_STRATEGIES.include?(c) } # Reject base classes
        .each{ |c| self.add(c.new) }
    end

    def register_base_strategies
      DEFAULT_STRATEGIES.each{ |c| self.add(c.new) }
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
