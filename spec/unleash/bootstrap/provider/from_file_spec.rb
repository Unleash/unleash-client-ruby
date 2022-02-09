require 'spec_helper'
require 'rspec/json_expectations'
require 'unleash/bootstrap/provider/from_file'
require 'json'

RSpec.describe Unleash::Bootstrap::Provider::FromFile do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
  end

  it 'loads bootstrap toggle correctly from file' do
    bootstrap_file = './spec/unleash/bootstrap-resources/features-v1.json'

    bootstrap_contents = Unleash::Bootstrap::Provider::FromFile.read(bootstrap_file)
    bootstrap_features = JSON.parse(bootstrap_contents)['features']

    file_contents = File.open(bootstrap_file).read
    file_features = JSON.parse(file_contents)['features']

    expect(bootstrap_features).to include_json(file_features)
  end
end
