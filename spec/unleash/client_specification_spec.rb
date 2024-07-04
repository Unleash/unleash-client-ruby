require 'unleash'
require 'unleash/client'
require 'unleash/configuration'
require 'unleash/variant'

RSpec.describe Unleash::Client do
  # load client spec
  SPECIFICATION_PATH = 'client-specification/specifications'.freeze

  DEFAULT_VARIANT = Unleash::Variant.new(name: 'unknown', enabled: false).freeze

  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
    Unleash.logger.level = Unleash.configuration.log_level
    Unleash.toggle_metrics = {}

    # Do not test metrics:
    Unleash.configuration.disable_metrics = true
  end

  unless File.exist?(SPECIFICATION_PATH + '/index.json')
    raise "Client specification tests not found, these are mandatory for a successful test run. You can download the client specification by running the following command:\n `git clone --branch v$(ruby echo_client_spec_version.rb) https://github.com/Unleash/client-specification.git`"
  end

  JSON.parse(File.read(SPECIFICATION_PATH + '/index.json')).each do |test_file|
    describe "for #{test_file}" do
      current_test_set = JSON.parse(File.read(SPECIFICATION_PATH + '/' + test_file))
      context "with #{current_test_set.fetch('name')} " do
        tests = current_test_set.fetch('tests', [])
        state = current_test_set.fetch('state', {})
        state_features = state.fetch('features', [])
        state_segments = state.fetch('segments', []).map{ |segment| [segment["id"], segment] }.to_h
        let(:unleash_toggles) { state_features }
        unleash_client = Unleash::Client.new

        tests.each do |test|
          it "test that #{test['description']}" do
            Unleash.toggles = unleash_toggles
            Unleash.segment_cache = state_segments

            context = Unleash::Context.new(test['context'])

            toggle_result = unleash_client.is_enabled?(test.fetch('toggleName'), context)

            expect(toggle_result).to eq(test['expectedResult'])
          end
        end

        variant_tests = current_test_set.fetch('variantTests', [])
        variant_tests.each do |test|
          it "test that #{test['description']}" do
            Unleash.toggles = unleash_toggles
            Unleash.segment_cache = state_segments

            context = Unleash::Context.new(test['context'])

            variant = unleash_client.get_variant(test.fetch('toggleName'), context)

            expect(variant).to eq(Unleash::Variant.new(test['expectedResult']))
          end
        end
      end
    end
  end
end
