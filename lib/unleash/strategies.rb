require 'unleash/strategy/base'
Gem.find_files('unleash/strategy/**/*.rb').each{ |path| require path }

module Unleash
  class Strategies
    def initialize
      @strategies = Unleash::Strategy.constants
        .select{ |c| Unleash::Strategy.const_get(c).is_a? Class }
        .reject{ |c| ['NotImplemented', 'Base'].include?(c.to_s) }
        .map do |strategy_class|
        strategy = Object.const_get("Unleash::Strategy::#{strategy_class}").new
        [strategy.name, strategy]
      end.to_h
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
  end
end
