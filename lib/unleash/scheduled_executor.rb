module Unleash

  class ScheduledExecutor
    attr_accessor :name, :interval, :max_exceptions, :retry_count

    def initialize(name, interval, max_exceptions = 5)
      self.name = name || ''
      self.interval = interval
      self.max_exceptions = max_exceptions
      self.retry_count = 0
    end

    def run(&blk)
      thread = Thread.new do
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
            Unleash.logger.info "thread #{name} retry_count (#{self.retry_count}) exceeded max_exceptions (#{self.max_exceptions}). Stopping with retries."
            break
          end
        end
        Unleash.logger.info "thread #{name} ended"
      end
    end
  end
end
