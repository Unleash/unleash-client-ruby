RSpec.describe Unleash do
  it "has a version number" do
    expect(Unleash::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(false)
  end

  context 'when configured' do
    before do
      Unleash.configure do |config|
        config.app_name = 'rspec_test'
        config.url = 'http://testurl/'
      end
    end

    it 'has configuration' do
      expect(described_class.configuration).to be_instance_of(Unleash::Configuration)
    end

    it 'proxies strategies to config' do
      expect(described_class.strategies).to eq(Unleash.configuration.strategies)
    end
  end

  it "mount custom strategies correctly" do
    class TestStrategy
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def enabled?(params, context)
        params["gerkhins"] == "yes"
      end
    end

    Unleash.configure do |config|
      config.app_name = 'rspec_test'
      config.strategies.register(TestStrategy.new)
    end

    custom_strategy = Unleash.configuration.strategies.strategies.find { |strategy| strategy.name == 'customStrategy' }

    expect(custom_strategy).to be_instance_of(CustomStrategy)
  end
end
