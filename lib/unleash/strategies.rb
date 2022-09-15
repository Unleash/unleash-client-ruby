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
      warn_deprecated_registration(strategy, 'modifying Unleash::STRATEGIES')
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

    # Deprecated: Use Unleash.configuration to add custom strategies
    def register_custom_strategies
      Unleash::Strategy.constants
        .select{ |c| Unleash::Strategy.const_get(c).is_a? Class }
        .reject{ |c| ['NotImplemented', 'Base'].include?(c.to_s) } # Reject abstract classes
        .map{ |c| Object.const_get("Unleash::Strategy::#{c}") }
        .reject{ |c| DEFAULT_STRATEGIES.include?(c) } # Reject base classes
        .each do |c|
        strategy = c.new
        warn_deprecated_registration(strategy, 'adding custom class into Unleash::Strategy namespace')
        self.add(strategy)
      end
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

    def warn_deprecated_registration(strategy, method)
      warn "[DEPRECATED] Registering custom Unleash strategy by #{method} is deprecated.
             Please use Unleash configuration to register custom strategy: " \
           "`Unleash.configure {|c| c.strategies.add(#{strategy.class.name}.new) }`"
    end
  end
end
