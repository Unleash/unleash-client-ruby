require 'unleash_extensions'

RSpec.describe UnleashExtensions do
  it "has an OpenTelemetry extension defined" do
    expect(UnleashExtensions::OpenTelemetry.Client.new).not_to be nil
  end
end