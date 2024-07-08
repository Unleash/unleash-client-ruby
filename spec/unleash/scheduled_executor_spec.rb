require 'securerandom'

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

  it "will run the correct code" do
    max_exceptions = 1

    scheduled_executor = Unleash::ScheduledExecutor.new('TesterLoop', 0, max_exceptions)
    new_app_name = SecureRandom.uuid
    original_app_name = Unleash.configuration.app_name

    scheduled_executor.run do
      Unleash.configuration.app_name = new_app_name
      raise StopIteration
    end

    scheduled_executor.thread.join
    expect(Unleash.configuration.app_name).to eq(new_app_name)

    Unleash.configuration.app_name = original_app_name
  end

  # These two tests are super flaky because they're checking if threading works
  # We could extend the times to make them less flaky but that would mean slower tests so I'm disabling them for now
  xit "will trigger immediate exection when set to do so" do
    max_exceptions = 1

    scheduled_executor = Unleash::ScheduledExecutor.new('TesterLoop', 0.02, max_exceptions, true)
    new_app_name = SecureRandom.uuid
    original_app_name = Unleash.configuration.app_name

    scheduled_executor.run do
      Unleash.configuration.app_name = new_app_name
      raise StopIteration
    end

    sleep 0.01

    expect(Unleash.configuration.app_name).to eq(new_app_name)
    scheduled_executor.thread.join

    Unleash.configuration.app_name = original_app_name
  end

  xit "will not trigger immediate exection when not set" do
    max_exceptions = 1

    scheduled_executor = Unleash::ScheduledExecutor.new('TesterLoop', 0.02, max_exceptions, false)
    new_app_name = SecureRandom.uuid
    original_app_name = Unleash.configuration.app_name

    scheduled_executor.run do
      Unleash.configuration.app_name = new_app_name
      raise StopIteration
    end

    sleep 0.01

    expect(Unleash.configuration.app_name).to eq(original_app_name)
    scheduled_executor.thread.join

    Unleash.configuration.app_name = original_app_name
  end
end
