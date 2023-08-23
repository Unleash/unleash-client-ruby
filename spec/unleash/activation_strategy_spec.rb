require 'unleash/constraint'
require 'unleash/variant_definition'

RSpec.describe Unleash::ActivationStrategy do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
  end

  let(:name) { 'test name' }

  describe '#initialize' do
    context 'with correct payload' do
      let(:params) { Hash.new(test: true) }
      let(:constraints) { [Unleash::Constraint.new("constraint_name", "IN", ["value"])] }
      let(:variant_definitions) { [Unleash::VariantDefinition.new("variant_name")] }

      it 'initializes with correct attributes' do
        expect(Unleash.logger).to_not receive(:warn)

        strategy = Unleash::ActivationStrategy.new(name, params, constraints, variant_definitions)

        expect(strategy.name).to eq name
        expect(strategy.params).to eq params
        expect(strategy.constraints).to eq constraints
        expect(strategy.variant_definitions).to eq variant_definitions
      end

      it 'fallbacks to empty array if variant definitions are invalid' do
        expect(Unleash.logger).to receive(:warn)

        strategy = Unleash::ActivationStrategy.new(
          name,
          params,
          constraints,
          [variant_definitions.first, "I am not a valid variant definition"]
        )

        expect(strategy.variant_definitions).to eq []
      end

      it 'fallbacks to empty array if constraint definitions are invalid' do
        expect(Unleash.logger).to receive(:warn)

        strategy = Unleash::ActivationStrategy.new(
          name,
          params,
          [constraints.first, "I am not a valid variant definition"],
          variant_definitions
        )

        expect(strategy.constraints).to eq []
      end
    end

    context 'with incorrect payload' do
      let(:params) { 'bad_params' }
      let(:constraints) { [] }

      it 'initializes with correct attributes and logs warning' do
        expect(Unleash.logger).to receive(:warn)

        strategy = Unleash::ActivationStrategy.new(name, params, constraints)

        expect(strategy.name).to eq name
        expect(strategy.params).to eq({})
        expect(strategy.constraints).to eq(constraints)
      end
    end
  end
end
