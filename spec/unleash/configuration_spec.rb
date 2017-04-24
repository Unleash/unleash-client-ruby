require "spec_helper"
require "unleash/client/configuration"

RSpec.describe Unleash::Client do

  describe 'Configuration' do
    it "should have the correct defaults" do
      config = Unleash::Client::Configuration.new()
      expect(config.instance_id).to be_truthy
      expect(config.timeout).to eq(30)
      expect(config.retry_limit).to eq(1)
    end
  end

end