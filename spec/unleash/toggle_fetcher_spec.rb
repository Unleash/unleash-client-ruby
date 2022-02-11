require "spec_helper"
require "unleash/toggle_fetcher"

RSpec.describe Unleash::ToggleFetcher do
  before do
    Unleash.configuration = Unleash::Configuration.new
  end

  describe '#is_enabled?' do
    it 'should not raise an IO error on first backup of toggles' do
      WebMock.stub_request(:get, "http://test-url/client/features")
        .with(
          headers: {
            'Accept' => '*/*',
            'Content-Type' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Unleash-Appname' => 'my-test-app',
            'Unleash-Instanceid' => 'rspec/test',
            'User-Agent' => 'Ruby',
            'X-Api-Key' => '123'
          }
        )
        .to_return(status: 200, body: '{}', headers: {})

      log_trapper = Object.new

      log_trapper.define_singleton_method(:warn) do |*args|
      end

      log_trapper.define_singleton_method(:error) do |*args|
        puts "INTERNAL SCCREAMING"
      end

      log_trapper.define_singleton_method(:debug) do |*args|
      end

      Unleash.logger = log_trapper
      Unleash.configuration.backup_file = './test_file_safe_to_delete_but_not_use'

      toggle_fetcher = Unleash::ToggleFetcher.new
    end
  end
end
