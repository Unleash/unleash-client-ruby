require 'spec_helper'

RSpec.describe Unleash::ToggleFetcher do
  subject(:toggle_fetcher) { Unleash::ToggleFetcher.new }

  before do
    Unleash.configure do |config|
      config.url      = 'http://toggle-fetcher-test-url/'
      config.app_name = 'toggle-fetcher-my-test-app'
      config.disable_client = false # Some test is changing the process state for this one
    end

    fetcher_features = {
      "version": 1,
      "features": [
        {
          "name": "Feature.A",
          "description": "Enabled toggle",
          "enabled": true,
          "strategies": [{ "name": "toggle-fetcher" }]
        }
      ]
    }

    WebMock.stub_request(:get, "http://toggle-fetcher-test-url/client/features")
      .to_return(status: 200,
                 body: fetcher_features.to_json,
                 headers: {})

    Unleash.logger = Unleash.configuration.logger
  end

  after do
    WebMock.reset!
    File.delete(Unleash.configuration.backup_file) if File.exist?(Unleash.configuration.backup_file)
  end

  describe '#save!' do
    context 'when toggle_cache generation fails' do
      before do
        allow(toggle_fetcher).to receive(:toggle_cache).and_raise(StandardError)
      end

      it 'swallows the error' do
        expect { toggle_fetcher.save! }.not_to raise_error
      end
    end

    context 'when toggle_cache with content is saved' do
      before do
        toggle_fetcher.toggle_cache = { features: [] }
      end

      it 'creates a file with toggle_cache in JSON' do
        toggle_fetcher.save!
        expect(File.exist?(Unleash.configuration.backup_file)).to eq(true)
        expect(File.read(Unleash.configuration.backup_file)).to eq('{"features":[]}')
      end
    end
  end

  describe '.new' do
    context 'when there are problems fetching toggles' do
      before do
        cache_creator = described_class.new
        cache_creator.toggle_cache = { features: [] }
        cache_creator.save!

        WebMock.stub_request(:get, "http://toggle-fetcher-test-url/client/features").to_return(status: 500)
      end

      it 'reads the backup file for values' do
        expect(toggle_fetcher.toggle_cache).to eq("features" => [])
      end
    end

    context 'when backup file does not exist' do
      before do
        File.delete(Unleash.configuration.backup_file) if File.exist?(Unleash.configuration.backup_file)
        WebMock.stub_request(:get, "http://toggle-fetcher-test-url/client/features").to_return(status: 500)
      end

      it 'returns an empty toggle_cache' do
        expect(toggle_fetcher.toggle_cache).to eq(nil)
      end
    end
  end
end
