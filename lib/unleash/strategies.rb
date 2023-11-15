module Unleash
  class Strategies
    attr_accessor :strategies

    def initialize
      @strategies = []
    end

    def add(strategy)
      @strategies << strategy
    end
  end
end
