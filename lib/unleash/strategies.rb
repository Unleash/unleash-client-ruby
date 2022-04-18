require 'unleash/strategy/base'
Gem.find_files('unleash/strategy/**/*.rb').each{ |path| require path }

module Unleash
  class Strategies
    def initialize
      @strategies = Unleash::Strategy.constants
        .select{ |c| Unleash::Strategy.const_get(c).is_a? Class }
        .reject{ |c| ['NotImplemented', 'Base'].include?(c.to_s) }
        .map do |c|
        lowered_c = c.to_s
        lowered_c[0] = lowered_c[0].downcase
        [lowered_c.to_sym, Object.const_get("Unleash::Strategy::#{c}").new]
      end.to_h
    end

    def keys
      @strategies.keys
    end

    def includes?(name)
      @strategies.has_key?(name)
    end

    def fetch(name)
      raise Unleash::Strategy::NotImplemented, "Strategy is not implemented" unless (strategy = @strategies[name])

      strategy
    end
  end
end
