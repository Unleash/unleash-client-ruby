require 'unleash/bootstrap/from_uri'
require 'json'

RSpec.describe Unleash::Bootstrap::FromUri do
  it 'loads bootstrap toggle correctly from URL' do
    bootstrap_file = './spec/unleash/bootstrap-resources/features-v1.json'

    file_contents = File.open(bootstrap_file).read
    file_features = JSON.parse(file_contents)['features']

    WebMock.stub_request(:get, "http://test-url/bootstrap-goodness")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: file_contents, headers: {})

    bootstrapper = Unleash::Bootstrap::FromUri.new('http://test-url/bootstrap-goodness', {})

    expect(bootstrapper.read).to include_json(file_features)
  end
end
