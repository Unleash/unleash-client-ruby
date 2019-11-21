require 'spec_helper'

RSpec.describe Unleash::ScheduledExecutor do
  # context 'parameters correctly assigned in initialization'
  it "can start and exit a thread" do
    scheduled_executor = Unleash::ScheduledExecutor.new('TesterLoop', 0.1)
    scheduled_executor.run do
      loop do
        sleep 0.1
      end
    end

    expect(scheduled_executor.running?).to be true
    scheduled_executor.exit
    expect(scheduled_executor.running?).to be false
  end

  # Test that it will correctly stop running after the provided number of exceptions
  it "will stop running after the configured number of failures" do
    max_exceptions = 2

    scheduled_executor = Unleash::ScheduledExecutor.new('TesterLoop', 0, max_exceptions)
    scheduled_executor.run do
      raise StopIteration
    end
    expect(scheduled_executor.thread).to_not be_nil

    scheduled_executor.thread.join

    expect(scheduled_executor.retry_count).to be == 1 + max_exceptions
    expect(scheduled_executor.running?).to be false
  end
end
