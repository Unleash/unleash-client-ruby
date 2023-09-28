# require_relative '../lib/unleash_extensions'
# require_relative '../lib/unleash_extensions/open_telemetry'
# require_relative '../lib/open_telemetry'
require 'unleash_extensions/open_telemetry'

RSpec.describe UnleashExtensions::OpenTelemetry do
  it "has an OpenTelemetry extension defined" do
    # expect(UnleashExtensions::OpenTelemetry.Client.new).not_to be nil
    unleash_client = Unleash::Client.new(
      url: 'http://test-client/',
      app_name: 'my-test-app',
      instance_id: 'rspec/test',
      disable_client: true,
    )

    expect(Unleash::Client.new).not_to be nil
  end
end