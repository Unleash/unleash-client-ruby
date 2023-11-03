require 'unleash'
require 'unleash/client'
require 'unleash/configuration'
require 'unleash/variant'

RSpec.describe Unleash::Client do
  # load client spec
  SPECIFICATION_PATH = 'client-specification/specifications'.freeze

  DEFAULT_VARIANT = Unleash::Variant.new(name: 'unknown', enabled: false).freeze

  before do
    Unleash.logger = Unleash.configuration.logger
    Unleash.logger.level = Unleash.configuration.log_level
  end

  if File.exist?(SPECIFICATION_PATH + '/index.json')
    JSON.parse(File.read(SPECIFICATION_PATH + '/index.json')).each do |test_file|
      describe "for #{test_file}" do
        current_test_set = JSON.parse(File.read(SPECIFICATION_PATH + '/' + test_file))

        context "with #{current_test_set.fetch('name')} " do
          tests = current_test_set.fetch('tests', [])
          state = current_test_set.fetch('state', {})
          tests.each do |test|
            it "test that #{test['description']}" do
              context = Unleash::Context.new(test['context'])

              unleash = Unleash::Client.new(
                app_name: 'bootstrap-test',
                instance_id: 'local-test-cli',
                disable_client: true,
                disable_metrics: true,
                bootstrap_config: Unleash::Bootstrap::Configuration.new(data: current_test_set.fetch('state', {}).to_json)
              )
              toggle_result = unleash.is_enabled?(test.fetch('toggleName'), context)

              expect(toggle_result).to eq(test['expectedResult'])
            end
          end

          variant_tests = current_test_set.fetch('variantTests', [])
          variant_tests.each do |test|
            it "test that #{test['description']}" do
              context = Unleash::Context.new(test['context'])

              unleash = Unleash::Client.new(
                app_name: 'bootstrap-test',
                instance_id: 'local-test-cli',
                disable_client: true,
                disable_metrics: true,
                bootstrap_config: Unleash::Bootstrap::Configuration.new(data: current_test_set.fetch('state', {}).to_json)
              )
              variant = unleash.get_variant(test.fetch('toggleName'), context)

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
