require "spec_helper"
require "unleash/proxy/client"

RSpec.describe Unleash::Proxy::Client do
  it "makes the correct request when using the proxy client" do
    simple_features = {
      "toggles": [
        {
          "name": "Feature.A",
          "enabled": true,
          "variant": {
            "name": "disabled",
            "enabled": false
          }
        },
        {
          "name": "Feature.B",
          "enabled": false,
          "variant": {
            "name": "disabled",
            "enabled": false
          }
        }
      ]
    }

    WebMock.stub_request(:get, "http://test-proxy-url/proxy")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Api-Key' => '123'
        }
      )
      .to_return(status: 200, body: simple_features.to_json, headers: {})

    # TODO: check if the url params should be camelCase (userId) or if it is ok as snake_case (user_id)
    WebMock.stub_request(:get, "http://test-proxy-url/proxy?environment=default&user_id=789")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Api-Key' => '123'
        }
      )
      .to_return(status: 200, body: simple_features.to_json, headers: {})

    unleash_client = Unleash::Proxy::Client.new(
      proxy_url: 'http://test-proxy-url/proxy',
      proxy_custom_http_headers: { 'X-API-KEY' => '123' }
    )

    expect(unleash_client).to be_a(Unleash::Proxy::Client)

    feature_a = unleash_client.is_enabled?("Feature.A")
    expect(feature_a).to be true

    expect(
      a_request(:get, "http://test-proxy-url/proxy")
        .with(headers: { 'Content-Type': 'application/json' })
        .with(headers: { 'X-API-KEY': '123', 'Content-Type': 'application/json' })
    ).to have_been_made.once

    context = Unleash::Context.new(user_id: 789)
    feature_b = unleash_client.is_enabled?("Feature.B", context)
    expect(feature_b).to be false
    expect(
      a_request(:get, "http://test-proxy-url/proxy?environment=default&user_id=789")
        .with(headers: { 'Content-Type': 'application/json' })
        .with(headers: { 'X-API-KEY': '123' })
    ).to have_been_made.once
  end

  it "can return variants too" do
    features_with_variants = {
      "toggles": [
        "name": "toggle-with-variants",
        "enabled": true,
        "variant": {
          "name": "with-payload-json",
          "payload": {
            "type": "json",
            "value": "{\"description\": \"this is data delivered as a json string\"}"
          },
          "enabled": true
        }
      ]
    }

    # TODO: check if the url params should be camelCase (userId) or if it is ok as snake_case (user_id)
    WebMock.stub_request(:get, "http://test-proxy-url/proxy?environment=default")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: features_with_variants.to_json, headers: {})

    unleash_client = Unleash::Proxy::Client.new(
      proxy_url: 'http://test-proxy-url/proxy'
    )

    variant = unleash_client.get_variant("toggle-with-variants")
    expect(variant).to eq Unleash::Variant.new(
      name: "with-payload-json",
      enabled: true,
      payload: {
        "type" => "json",
        "value" => "{\"description\": \"this is data delivered as a json string\"}"
      }
    )

    expect(
      a_request(:get, "http://test-proxy-url/proxy?environment=default")
        .with(headers: { 'Content-Type': 'application/json' })
    ).to have_been_made.once
  end
end
