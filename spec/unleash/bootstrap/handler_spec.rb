require 'unleash/bootstrap/handler'
require 'unleash/bootstrap/configuration'
require "spec_helper"

RSpec.describe Unleash::Bootstrap::Handler do
  Unleash.configure do |config|
    config.url      = 'http://unleash-url/'
    config.app_name = 'my-test-app'
    config.instance_id = 'rspec/test'
    config.custom_http_headers = { 'X-API-KEY' => '123' }
  end

  it 'is marked as invalid when no bootstrap options are provided' do
    bootstrap_config = Unleash::Bootstrap::Configuration.new
    expect(bootstrap_config.valid?).to be(false)
  end

  it 'is marked as valid when at least one valid bootstrap option is provided' do
    bootstrap_config = Unleash::Bootstrap::Configuration.new({ 'data' => '' })
    expect(bootstrap_config.valid?).to be(true)
  end

  it 'resolves bootstrap toggle correctly from url provider' do
    expected_repsonse_data = '{
      "version": 1,
      "features": [
        {
          "name": "featureX",
          "enabled": true,
          "strategies": [{ "name": "default" }]
        }
      ]
    }'

    WebMock.stub_request(:get, "http://test-url/")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: expected_repsonse_data, headers: {})

    url_provider_options = {
      'url' => 'http://test-url/',
      'url_headers' => {}
    }

    bootstrap_config = Unleash::Bootstrap::Configuration.new(url_provider_options)
    bootstrap_response = Unleash::Bootstrap::Handler.new(bootstrap_config).retrieve_toggles
    expect(JSON.parse(bootstrap_response)).to eq(JSON.parse(expected_repsonse_data))
  end

  it 'resolves bootstrap toggle correctly from file provider' do
    file_path = './spec/unleash/bootstrap-resources/features-v1.json'
    actual_file_contents = File.open(file_path).read

    file_provider_options = {
      'file_path' => file_path
    }

    bootstrap_config = Unleash::Bootstrap::Configuration.new(file_provider_options)
    bootstrap_response = Unleash::Bootstrap::Handler.new(bootstrap_config).retrieve_toggles

    expect(JSON.parse(bootstrap_response)).to eq(JSON.parse(actual_file_contents))
  end

  it 'resolves bootstrap toggle correctly from raw data' do
    expected_repsonse_data = '{
      "version": 1,
      "features": [
        {
          "name": "featureX",
          "enabled": true,
          "strategies": [{ "name": "default" }]
        }
      ]
    }'

    data_provider_options = {
      'data' => expected_repsonse_data
    }

    bootstrap_config = Unleash::Bootstrap::Configuration.new(data_provider_options)
    bootstrap_response = Unleash::Bootstrap::Handler.new(bootstrap_config).retrieve_toggles

    expect(JSON.parse(bootstrap_response)).to eq(JSON.parse(expected_repsonse_data))
  end

  it 'resolves bootstrap toggle correctly from lambda' do
    expected_repsonse_data = '{
      "version": 1,
      "features": [
        {
          "name": "featureX",
          "enabled": true,
          "strategies": [{ "name": "default" }]
        }
      ]
    }'

    data_provider_options = {
      'block' => -> { expected_repsonse_data }
    }

    bootstrap_config = Unleash::Bootstrap::Configuration.new(data_provider_options)
    bootstrap_response = Unleash::Bootstrap::Handler.new(bootstrap_config).retrieve_toggles

    expect(JSON.parse(bootstrap_response)).to eq(JSON.parse(expected_repsonse_data))
  end
end
