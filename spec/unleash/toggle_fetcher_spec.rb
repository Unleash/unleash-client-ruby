require 'spec_helper'

RSpec.describe Unleash::ToggleFetcher do
  subject(:toggle_fetcher) { Unleash::ToggleFetcher.new }

  describe '#save!' do
    before do
      Unleash.configure do |config|
        config.url      = 'http://toggle-fetcher-test-url/'
        config.app_name = 'toggle-fetcher-my-test-app'
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
end
