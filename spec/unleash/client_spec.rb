require "spec_helper"

RSpec.describe Unleash::Client do
  it "Uses custom http headers when initializing client" do
    WebMock.stub_request(:post, "http://test-url/client/register")
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
    WebMock.stub_request(:post, "http://test-url/client/metrics")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    simple_features = {
      "version": 1,
      "features": [
        {
          "name": "Feature.A",
          "description": "Enabled toggle",
          "enabled": true,
          "strategies": [{ "name": "default" }]
        }
      ]
    }
    WebMock.stub_request(:get, "http://test-url/client/features")
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
      .to_return(status: 200, body: simple_features.to_json, headers: {})

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
      a_request(:post, "http://test-url/client/register")
      .with(headers: { 'Content-Type': 'application/json' })
      .with(headers: { 'X-API-KEY': '123', 'Content-Type': 'application/json' })
      .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
      .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).to have_been_made.once

    expect(
      a_request(:get, "http://test-url/client/features")
      .with(headers: { 'X-API-KEY': '123' })
      .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
      .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).to have_been_made.once

    # Test now sending of metrics
    # Not sending metrics, if no feature flags were evaluated:
    Unleash.reporter.post
    expect(
      a_request(:post, "http://test-url/client/metrics")
        .with(headers: { 'Content-Type': 'application/json' })
        .with(headers: { 'X-API-KEY': '123', 'Content-Type': 'application/json' })
        .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
        .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).not_to have_been_made

    # Sending metrics, if they have been evaluated:
    unleash_client.is_enabled?("Feature.A")
    Unleash.reporter.post
    expect(
      a_request(:post, "http://test-url/client/metrics")
      .with(headers: { 'Content-Type': 'application/json' })
      .with(headers: { 'X-API-KEY': '123', 'Content-Type': 'application/json' })
      .with(headers: { 'UNLEASH-APPNAME': 'my-test-app' })
      .with(headers: { 'UNLEASH-INSTANCEID': 'rspec/test' })
    ).to have_been_made.once
  end

  it "should load/use correct variants from the unleash server" do
    WebMock.stub_request(:post, "http://test-url/client/register")
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
      "features": [
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
      ]
    }'

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
      .to_return(status: 200, body: features_response_body, headers: {})

    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.disable_metrics = true
      config.custom_http_headers = { 'X-API-KEY' => '123' }
      config.log_level = Logger::DEBUG
    end

    unleash_client = Unleash::Client.new

    expect(
      unleash_client.is_enabled?('toggleName', {}, true)
    ).to eq(true)

    expect(WebMock).not_to have_requested(:get, 'http://test-url/')
    expect(WebMock).to have_requested(:post, 'http://test-url/client/register')
    expect(WebMock).to have_requested(:get, 'http://test-url/client/features')
  end

  it "should load/use correct variants from a bootstrap source" do
    bootstrap_values = '{
      "version": 1,
      "features": [
        {
          "name": "featureX",
          "enabled": true,
          "strategies": [{ "name": "default" }]
        }
      ]
    }'

    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.disable_client = true
      config.disable_metrics = true
      config.custom_http_headers = { 'X-API-KEY' => '123' }
      config.log_level = Logger::DEBUG
      config.bootstrap_config = Unleash::Bootstrap::Configuration.new({ 'data' => bootstrap_values })
    end

    expect(Unleash.configuration.bootstrap_config.data).to eq(bootstrap_values)

    unleash_client = Unleash::Client.new
    expect(
      unleash_client.is_enabled?('featureX', {}, false)
    ).to be true

    expect(WebMock).not_to have_requested(:get, 'http://test-url/')
    expect(WebMock).not_to have_requested(:post, 'http://test-url/client/register')
    expect(WebMock).not_to have_requested(:get, 'http://test-url/client/features')
  end

  it "should not fail if we are provided no toggles from the unleash server" do
    WebMock.stub_request(:post, "http://test-url/client/register")
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

    WebMock.stub_request(:get, "http://test-url/client/features")
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
      config.disable_client = false
      config.disable_metrics = true
      config.custom_http_headers = { 'X-API-KEY' => '123' }
    end

    unleash_client = Unleash::Client.new

    expect(
      unleash_client.is_enabled?('any_feature', {}, true)
    ).to eq(true)

    expect(WebMock).not_to have_requested(:get, 'http://test-url/')
    expect(WebMock).to have_requested(:get, 'http://test-url/client/features')
    expect(WebMock).to have_requested(:post, 'http://test-url/client/register')
    expect(WebMock).not_to have_requested(:post, 'http://test-url/client/metrics')
  end

  it "should return default results via block or param if running with disable_client" do
    Unleash.configure do |config|
      config.disable_client = true
    end
    unleash_client = Unleash::Client.new

    expect(
      unleash_client.is_enabled?('any_feature')
    ).to be false

    expect(
      unleash_client.is_enabled?('any_feature', {}, true)
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature2', {}, false)
    ).to be false

    expect(
      unleash_client.is_enabled?('any_feature3') { true }
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature3') { false }
    ).to be false

    expect(
      unleash_client.is_enabled?('any_feature3', {}) { true }
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature3', {}) { false }
    ).to be false

    expect(
      unleash_client.is_enabled?('any_feature5', {}) { nil }
    ).to be false

    # should never really send both the default value and a default block,
    # but if it is done, we OR the two values
    expect(
      unleash_client.is_enabled?('any_feature3', {}, true) { true }
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature3', {}, false) { true }
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature3', {}, true) { false }
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature3', {}, false) { false }
    ).to be false

    expect(
      unleash_client.is_enabled?('any_feature5', {}) { 'random_string' }
    ).to be true # expect "a string".to be_truthy

    expect do |b|
      unleash_client.is_enabled?('any_feature3', &b).to yield_with_no_args
    end

    expect do |b|
      unleash_client.is_enabled?('any_feature3', {}, &b).to yield_with_no_args
    end

    expect do |b|
      unleash_client.is_enabled?('any_feature3', {}, true, &b).to yield_with_no_args
    end

    number_eight = 8
    expect(
      unleash_client.is_enabled?('any_feature5', {}) do
        number_eight >= 5
      end
    ).to be true

    expect(
      unleash_client.is_enabled?('any_feature5', {}) do
        number_eight < 5
      end
    ).to be false

    context_params = {
      session_id: 'verylongsesssionid',
      remote_address: '127.0.0.2',
      properties: {
        env: 'dev'
      }
    }
    unleash_context = Unleash::Context.new(context_params)
    expect(
      unleash_client.is_enabled?('any_feature6', unleash_context) do |feature, context|
        feature == 'any_feature6' && \
        context.remote_address == '127.0.0.2' && context.session_id.length == 18 && context.properties[:env] == 'dev'
      end
    ).to be true

    proc = proc do |_feat, ctx|
      ctx.remote_address.starts_with?("127.0.0.")
    end
    expect(
      unleash_client.is_enabled?('any_feature6', unleash_context) { proc }
    ).to be true
    expect(
      unleash_client.is_enabled?('any_feature6', unleash_context, true) { proc }
    ).to be true
    expect(
      unleash_client.is_enabled?('any_feature6', unleash_context, false) { proc }
    ).to be true

    proc_feat = proc do |feat, _ctx|
      feat != 'feature6'
    end
    expect(
      unleash_client.is_enabled?('feature6', unleash_context, &proc_feat)
    ).to be false
    expect(
      unleash_client.is_enabled?('feature6', unleash_context, true, &proc_feat)
    ).to be true
    expect(
      unleash_client.is_enabled?('feature6', unleash_context, false, &proc_feat)
    ).to be false
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
    expect(WebMock).not_to have_requested(:get, 'http://test-url/client/features')
    expect(WebMock).not_to have_requested(:post, 'http://test-url/client/features')
    expect(WebMock).not_to have_requested(:post, 'http://test-url/client/register')
    expect(WebMock).not_to have_requested(:post, 'http://test-url/client/metrics')
  end

  it "should yield correctly to block when using if_enabled" do
    unleash_client = Unleash::Client.new

    expect{ |b| unleash_client.if_enabled('any_feature', {}, true, &b).to yield_with_no_args }
    expect{ |b| unleash_client.if_enabled('any_feature', {}, false, &b).not_to yield_with_no_args }
  end

  describe 'get_variant' do
    let(:disable_client) { false }
    let(:client) { Unleash::Client.new }
    let(:feature) { 'awesome-feature' }
    let(:fallback_variant) { Unleash::Variant.new(name: 'default', enabled: true) }
    let(:variants) do
      [
        {
          name: "a",
          weight: 50,
          stickiness: "default",
          payload: {
            type: "string",
            value: ""
          }
        }
      ]
    end
    let(:body) do
      {
        version: 1,
        features: [
          {
            name: feature,
            enabled: true,
            strategies: [
              { name: "default" }
            ],
            variants: variants
          }
        ]
      }.to_json
    end

    before do
      WebMock.stub_request(:post, "http://test-url/client/register")
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
        .to_return(status: 200, body: '', headers: {})

      WebMock.stub_request(:get, "http://test-url/client/features")
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
        .to_return(status: 200, body: body, headers: {})

      Unleash.toggles = []
      Unleash.configure do |config|
        config.url      = 'http://test-url/'
        config.app_name = 'my-test-app'
        config.disable_client = disable_client
        config.custom_http_headers = { 'X-API-KEY' => '123' }
      end
    end

    it 'returns variant' do
      ret = client.get_variant(feature)
      expect(ret.name).to eq 'a'
    end

    context 'when disable_client is false' do
      let(:disable_client) { true }

      context 'when fallback variant is specified' do
        it 'returns given fallback variant' do
          expect(client.get_variant(feature, nil, fallback_variant)).to be fallback_variant
        end
      end

      context 'when fallback variant is not specified' do
        it 'returns a disabled variant' do
          ret = client.get_variant(feature)
          expect(ret.enabled).to be false
          expect(ret.name).to eq 'disabled'
        end
      end
    end

    context 'when feature is not found' do
      context 'when fallback variant is specified' do
        it 'returns given fallback variant' do
          expect(client.get_variant('something', nil, fallback_variant)).to be fallback_variant
        end
      end

      context 'when fallback variant is not specified' do
        it 'returns a disabled variant' do
          ret = client.get_variant('something')
          expect(ret.enabled).to be false
          expect(ret.name).to eq 'disabled'
        end
      end
    end

    context 'when feature does not have variants' do
      let(:variants) { [] }

      it 'returns a disabled variant' do
        ret = client.get_variant(feature)
        expect(ret.enabled).to be false
        expect(ret.name).to eq 'disabled'
      end
    end
  end
end
