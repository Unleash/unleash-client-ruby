require 'unleash'
require 'unleash/client'
require 'unleash/configuration'
require 'unleash/variant'

RSpec.describe Unleash::Client do
  # load client spec
  SPECIFICATION_PATH = 'client-specification/specifications'.freeze

  before do
    Unleash.configuration = Unleash::Configuration.new

    Unleash.logger = Unleash.configuration.logger
    Unleash.logger.level = Unleash.configuration.log_level

    Unleash.configuration.disable_metrics = true
  end

  unless File.exist?(SPECIFICATION_PATH + '/index.json')
    raise "Client specification tests not found, these are mandatory for a successful test run. "\
    "You can download the client specification by running the following command:\n "\
    "`git clone --branch v$(ruby echo_client_spec_version.rb) https://github.com/Unleash/client-specification.git`"
  end

  JSON.parse(File.read(SPECIFICATION_PATH + '/index.json')).each do |test_file|
    describe "for #{test_file}" do
      ## Encoding is set in this read purely for JRuby. Don't take this out, it'll work locally and then fail on CI
      current_test_set = JSON.parse(File.read(SPECIFICATION_PATH + '/' + test_file, encoding: 'utf-8'))
      context "with #{current_test_set.fetch('name')} " do
        tests = current_test_set.fetch('tests', [])
        tests.each do |test|
          it "test that #{test['description']}" do
            context = Unleash::Context.new(test['context'])

            unleash = Unleash::Client.new(
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
end
