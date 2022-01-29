require 'spec_helper'
require 'rspec/json_expectations'
require 'unleash/bootstrap/base'
require 'unleash/bootstrap/from_file'
require 'json'

RSpec.describe Unleash::Bootstrap::FromFile do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
  end

  it 'loads bootstrap toggle correctly from file' do
    bootstrap_file = './spec/unleash/bootstrap-resources/features-v1.json'

    bootstrapper = Unleash::Bootstrap::FromFile.new(bootstrap_file)
    file_contents = File.open(bootstrap_file).read
    file_features = JSON.parse(file_contents)['features']

    expect(bootstrapper.read).to include_json(file_features)
  end
end
