module Unleash
  class Strategies
    attr_accessor :strategies

    def initialize
      @strategies = []
    end

    def register(strategy)
      @strategies << strategy
    end
  end
end
