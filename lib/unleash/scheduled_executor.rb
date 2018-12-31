module Unleash

  class ScheduledExecutor
    attr_accessor :name, :interval, :max_exceptions, :retry_count, :thread

    def initialize(name, interval, max_exceptions = 5)
      self.name = name || ''
      self.interval = interval
      self.max_exceptions = max_exceptions
      self.retry_count = 0
      self.thread = nil
    end

    def run(&blk)
      self.thread = Thread.new do
        Thread.current[:name] = self.name

        loop do
          Unleash.logger.debug "thread #{name} sleeping for #{interval} seconds"
          sleep interval

          Unleash.logger.debug "thread #{name} started"
          begin
            yield
            self.retry_count = 0
          rescue Exception => e
            self.retry_count += 1
            Unleash.logger.error "thread #{name} threw exception #{e.class}:'#{e}' (#{self.retry_count}/#{self.max_exceptions})"
            Unleash.logger.error "stacktrace: #{e.backtrace}"
          end

          if self.retry_count > self.max_exceptions
            Unleash.logger.error "thread #{name} retry_count (#{self.retry_count}) exceeded max_exceptions (#{self.max_exceptions}). Stopping with retries."
            break
          end
        end
        Unleash.logger.warn "thread #{name} loop ended"
      end
    end

    def running?
      self.thread.is_a?(Thread) && self.thread.alive?
    end

    def exit
      if self.running?
        Unleash.logger.warn "thread #{name} will exit!"
        self.thread.exit
        self.thread.join if self.running?
      end
    end
  end
end
