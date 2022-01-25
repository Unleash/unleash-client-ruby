require 'spec_helper'
require 'unleash/constraint'
require 'unleash/bootstrap'
require 'json'

RSpec.describe Unleash::Client do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
  end

  describe 'Bootstrap' do
    it 'loads bootstrap toggle correctly from file' do
      bootstrapper = Unleash::FileBootStrapper.new('./spec/unleash/bootstrap-resources/features-v1.json')
      bootstrapper.read
    end

    it 'loads bootstrap toggle correctly from URL' do
      WebMock.stub_request(:get, "http://test-url/bootstrap-goodness")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'Host' => 'test-url',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: "", headers: {})

      bootstrapper = Unleash::UrlBootStrapper.new('http://test-url/bootstrap-goodness', nil)
      bootstrapper.read
    end
  end
end
