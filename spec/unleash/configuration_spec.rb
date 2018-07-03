require "spec_helper"
require "unleash/configuration"

RSpec.describe Unleash do

  describe 'Configuration' do
    it "should have the correct defaults" do
      config = Unleash::Configuration.new()

      expect(config.app_name).to be_nil
      expect(config.url).to be_nil
      expect(config.instance_id).to be_truthy
      expect(config.disable_metrics).to be_falsey

      expect(config.refresh_interval).to eq(15)
      expect(config.metrics_interval).to eq(10)
      expect(config.timeout).to eq(30)
      expect(config.retry_limit).to eq(1)

      # expect(config.validate!).to raise_error(ArgumentError)
      expect(config.backup_file).to_not be_nil
    end

    it "should by default be invalid" do
      config = Unleash::Configuration.new()
      expect{ config.validate! }.to raise_error(ArgumentError)
    end

    it "should be valid with the mandatory arguments set" do
      config = Unleash::Configuration.new(app_name: 'rspec_test', url: 'http://testurl/')
      expect{ config.validate! }.not_to raise_error
    end

    it "support yield for setting the configuration" do
      Unleash.configure do |config|
        config.url      = 'http://test-url/'
        config.app_name = 'my-test-app'
      end
      expect{ Unleash.configuration.validate! }.not_to raise_error
      expect(Unleash.configuration.url).to eq('http://test-url/')
      expect(Unleash.configuration.app_name).to eq('my-test-app')
      expect(Unleash.configuration.fetch_toggles_url).to eq('http://test-url//client/features')
    end

    it "should build the correct unleash endpoints from the base url" do
      config = Unleash::Configuration.new(url: 'https://testurl/api', app_name: 'test-app')
      expect(config.url).to eq('https://testurl/api')
      expect(config.fetch_toggles_url).to eq('https://testurl/api/client/features')
      expect(config.client_metrics_url).to eq('https://testurl/api/client/metrics')
      expect(config.client_register_url).to eq('https://testurl/api/client/register')
    end

  end

end