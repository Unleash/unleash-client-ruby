require 'unleash/bootstrap/provider/from_url'
require 'json'

RSpec.describe Unleash::Bootstrap::Provider::FromUrl do
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

    bootstrap_contents = Unleash::Bootstrap::Provider::FromUrl.read('http://test-url/bootstrap-goodness', {})
    bootstrap_features = JSON.parse(bootstrap_contents)['features']

    expect(bootstrap_features).to include_json(file_features)
  end
end
