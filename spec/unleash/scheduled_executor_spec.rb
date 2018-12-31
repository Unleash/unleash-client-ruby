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
end
