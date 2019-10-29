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

        Unleash.logger.debug "thread #{name} loop starting"
        loop do
          Unleash.logger.debug "thread #{name} sleeping for #{interval} seconds"
          sleep interval

          run_blk(blk)

          if exceeded_max_exceptions?
            Unleash.logger.error "thread #{name} retry_count (#{self.retry_count}) exceeded " \
                "max_exceptions (#{self.max_exceptions}). Stopping with retries."
            break
          end
        end
        Unleash.logger.debug "thread #{name} loop ended"
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
      else
        Unleash.logger.info "thread #{name} was already stopped!"
      end
    end

    private

    def run_blk(blk)
      Unleash.logger.debug "thread #{name} starting execution"

      yield(*blk)
      self.retry_count = 0
    rescue StandardError => e
      self.retry_count += 1
      Unleash.logger.error "thread #{name} threw exception #{e.class} " \
          " (#{self.retry_count}/#{self.max_exceptions}): '#{e}'"
      Unleash.logger.debug "stacktrace: #{e.backtrace}"
    end

    def exceeded_max_exceptions?
      self.retry_count > self.max_exceptions
    end
  end
end
