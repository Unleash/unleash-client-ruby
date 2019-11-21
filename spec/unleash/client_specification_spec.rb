require 'spec_helper'
require 'unleash'
require 'unleash/client'
require 'unleash/configuration'
require 'unleash/variant'

RSpec.describe Unleash::Client do
  # load client spec
  SPECIFICATION_PATH = 'client-specification/specifications'.freeze

  DEFAULT_RESULT = false
  DEFAULT_VARIANT = Unleash::Variant.new(name: 'unknown', enabled: false).freeze

  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
    Unleash.logger.level = Unleash.configuration.log_level
    Unleash.toggles = []
    Unleash.toggle_metrics = {}

    # Do not test metrics:
    Unleash.configuration.disable_metrics = true
  end

  if File.exist?(SPECIFICATION_PATH + '/index.json')
    JSON.parse(File.read(SPECIFICATION_PATH + '/index.json')).each do |test_file|
      describe "for #{test_file}" do
        current_test_set = JSON.parse(File.read(SPECIFICATION_PATH + '/' + test_file))
        context "with #{current_test_set.fetch('name')} " do
          # name = current_test_set.fetch('name', '')
          tests = current_test_set.fetch('tests', [])
          state = current_test_set.fetch('state', {})
          state_features = state.fetch('features', [])

          let(:unleash_toggles) { state_features }

          tests.each do |test|
            it "test that #{test['description']}" do
              test_toggle = unleash_toggles.select{ |t| t.fetch('name', '') == test.fetch('toggleName') }.first

              toggle = Unleash::FeatureToggle.new(test_toggle)
              context = Unleash::Context.new(test['context'])

              toggle_result = toggle.is_enabled?(context, DEFAULT_RESULT)

              expect(toggle_result).to eq(test['expectedResult'])
            end
          end

          variant_tests = current_test_set.fetch('variantTests', [])
          variant_tests.each do |test|
            it "test that #{test['description']}" do
              test_toggle = unleash_toggles.select{ |t| t.fetch('name', '') == test.fetch('toggleName') }.first

              toggle = Unleash::FeatureToggle.new(test_toggle)
              context = Unleash::Context.new(test['context'])

              variant = toggle.get_variant(context, DEFAULT_VARIANT)

              expect(variant).to eq(Unleash::Variant.new(test['expectedResult']))
            end
          end
        end
      end
    end
  else
    xit "Skipped client-specification tests. #{SPECIFICATION_PATH} not found." do
      # If you want to run the client-specification tests locally, run from the root path of the repo:
      # git clone --depth 5 https://github.com/Unleash/client-specification.git client-specification
    end
  end
end
