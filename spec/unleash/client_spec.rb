require "spec_helper"

RSpec.describe Unleash do
  it "has a version number" do
    expect(Unleash::VERSION).not_to be nil
  end

  it "Uses custom http headers when initializing client" do
    WebMock.stub_request(:post, "http://test-url//client/register")
      .with(
        headers: {
        'Accept'=>'*/*',
        'Content-Type'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby',
        'X-Api-Key'=>'123'
        })
      .to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:post, "http://test-url//client/metrics").
       with(
         headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/json',
        'User-Agent'=>'Ruby'
         }).
       to_return(status: 200, body: "", headers: {})


    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.custom_http_headers = {'X-API-KEY' => '123'}
    end

    unleash_client = Unleash::Client.new(
      url: 'http://test-url/',
      app_name: 'my-test-app',
      instance_id: 'rspec/test',
      custom_http_headers: {'X-API-KEY' => '123'}
    )

    expect(
      a_request(:post, "http://test-url//client/register")
      .with( headers: {'Content-Type': 'application/json'})
      .with( headers: {'X-API-KEY': '123', 'Content-Type': 'application/json'})
      .with( headers: {'UNLEASH-APPNAME': 'my-test-app'})
      .with( headers: {'UNLEASH-INSTANCEID': 'rspec/test'})
    ).to have_been_made.once

    expect(
      a_request(:get, "http://test-url//client/features")
      .with( headers: {'X-API-KEY': '123'})
      .with( headers: {'UNLEASH-APPNAME': 'my-test-app'})
      .with( headers: {'UNLEASH-INSTANCEID': 'rspec/test'})
    ).to have_been_made.once

    # Test now sending of metrics
    Unleash.reporter.send
    expect(
      a_request(:post, "http://test-url//client/metrics")
      .with( headers: {'Content-Type': 'application/json'})
      .with( headers: {'X-API-KEY': '123', 'Content-Type': 'application/json'})
      .with( headers: {'UNLEASH-APPNAME': 'my-test-app'})
      .with( headers: {'UNLEASH-INSTANCEID': 'rspec/test'})
    ).to have_been_made.once
  end

  it "does something useful" do
    expect(false).to eq(false)
  end
end
