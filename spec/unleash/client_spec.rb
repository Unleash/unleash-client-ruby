require "spec_helper"

RSpec.describe Unleash::Client do
  it "Uses custom http headers when initializing client" do
    WebMock.stub_request(:post, "http://test-url//client/register")
      .with(
        headers: {
          'Accept' => '*/*',
          'Content-Type' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby',
          'X-Api-Key' => '123'
        }
      )
      .to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:post, "http://test-url//client/metrics")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:get, "http://test-url//client/features")
      .with(
         headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'Unleash-Appname' => 'my-test-app',
          'Unleash-Instanceid' => 'rspec/test',
          'User-Agent' => 'Ruby',
          'X-Api-Key' => '123'
         }
       )
       .to_return(status: 200, body: "", headers: {})

    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.custom_http_headers = { 'X-API-KEY' => '123' }
    end

    unleash_client = Unleash::Client.new(
      url: 'http://test-url/',
      app_name: 'my-test-app',
      instance_id: 'rspec/test',
      custom_http_headers: { 'X-API-KEY' => '123' }
    )

    expect(unleash_client).to be_a(Unleash::Client)

    expect(
      a_request(:post, "http://test-url//client/register")
      .with(headers: { 'Content-Type': 'application/json' })
      .with(headers: { 'X-API-KEY': '123', 'Content-Type': 'application/json' })
      .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
      .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).to have_been_made.once

    expect(
      a_request(:get, "http://test-url//client/features")
      .with(headers: { 'X-API-KEY': '123' })
      .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
      .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).to have_been_made.once

    # Test now sending of metrics
    Unleash.reporter.send
    expect(
      a_request(:post, "http://test-url//client/metrics")
      .with(headers: { 'Content-Type': 'application/json' })
      .with(headers: { 'X-API-KEY': '123', 'Content-Type': 'application/json' })
      .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
      .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).to have_been_made.once
  end

  it "should load/use correct variants from the unleash server" do
    WebMock.stub_request(:post, "http://test-url//client/register")
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
      .to_return(status: 200, body: "", headers: {})

    features_response_body = '{
      "version": 1,
      "features": {
        "name": "toggleName",
        "enabled": true,
        "strategies": [{ "name": "default" }],
        "variants": [
          {
            "name": "a",
            "weight": 50,
            "payload": {
              "type": "string",
              "value": ""
            }
          },
          {
            "name": "b",
            "weight": 50,
            "payload": {
              "type": "string",
              "value": ""
            }
          }
        ]
      }
    }'

    WebMock.stub_request(:get, "http://test-url//client/features")
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
      .to_return(status: 200, body: features_response_body, headers: {})

    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.disable_metrics = true
      config.custom_http_headers = { 'X-API-KEY' => '123' }
      config.log_level = Logger::DEBUG
    end

    unleash_client = Unleash::Client.new(
      url: 'http://test-url/',
      app_name: 'my-test-app',
      instance_id: 'rspec/test',
      custom_http_headers: { 'X-API-KEY' => '123' }
    )

    expect(
      unleash_client.is_enabled?('toggleName', {}, true)
    ).to eq(true)

    expect(WebMock).not_to have_requested(:get, 'http://test-url/')
    expect(WebMock).to have_requested(:post, 'http://test-url//client/register')
    expect(WebMock).to have_requested(:get, 'http://test-url//client/features')
  end

  it "should not fail if we are provided no toggles from the unleash server" do
    WebMock.stub_request(:post, "http://test-url//client/register")
      .with(
        headers: {
          'Accept' => '*/*',
          'Content-Type' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby',
          'X-Api-Key' => '123'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    WebMock.stub_request(:get, "http://test-url//client/features")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'Unleash-Appname' => 'my-test-app',
          'Unleash-Instanceid' => 'rspec/test',
          'User-Agent' => 'Ruby',
          'X-Api-Key' => '123'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.disable_metrics = true
      config.custom_http_headers = { 'X-API-KEY' => '123' }
    end

    unleash_client = Unleash::Client.new(
      url: 'http://test-url/',
      app_name: 'my-test-app',
      instance_id: 'rspec/test',
      custom_http_headers: { 'X-API-KEY' => '123' }
    )

    expect(
      unleash_client.is_enabled?('any_feature', {}, true)
    ).to eq(true)

    expect(WebMock).not_to have_requested(:get, 'http://test-url/')
    expect(WebMock).to have_requested(:get, 'http://test-url//client/features')
    expect(WebMock).to have_requested(:post, 'http://test-url//client/register')
    expect(WebMock).not_to have_requested(:post, 'http://test-url//client/metrics')
  end

  it "should return default results if running with disable_client" do
    Unleash.configure do |config|
      config.disable_client = true
    end
    unleash_client = Unleash::Client.new

    expect(
      unleash_client.is_enabled?('any_feature', {}, true)
    ).to eq(true)

    expect(
      unleash_client.is_enabled?('any_feature2', {}, false)
    ).to eq(false)
  end

  it "should not connect anywhere if running with disable_client" do
    Unleash.configure do |config|
      config.disable_client = true
      config.url = 'http://test-url/'
      config.custom_http_headers = 'invalid_string'
    end

    unleash_client = Unleash::Client.new

    expect(
      unleash_client.is_enabled?('any_feature', {}, true)
    ).to eq(true)

    expect(WebMock).not_to have_requested(:get, 'http://test-url/')
    expect(WebMock).not_to have_requested(:get, 'http://test-url//client/features')
    expect(WebMock).not_to have_requested(:post, 'http://test-url//client/features')
    expect(WebMock).not_to have_requested(:post, 'http://test-url//client/register')
    expect(WebMock).not_to have_requested(:post, 'http://test-url//client/metrics')
  end

  it "should yield correctly to block when using if_enabled" do
    unleash_client = Unleash::Client.new

    expect{ |b| unleash_client.if_enabled('any_feature', {}, true, &b).to yield_with_no_args }
    expect{ |b| unleash_client.if_enabled('any_feature', {}, false, &b).not_to yield_with_no_args }
  end
end
