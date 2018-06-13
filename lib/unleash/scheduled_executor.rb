module Unleash

  class ScheduledExecutor
    attr_accessor :interval

    def initialize(interval)
        self.interval = interval
    end
  end
end