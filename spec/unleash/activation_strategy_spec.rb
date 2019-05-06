require 'spec_helper'

RSpec.describe Unleash::ActivationStrategy do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
  end
  let(:name) { 'test name' }

  describe '#initialize' do
    context 'with correct payload' do
      let(:params) { Hash.new(test: true) }

      it 'initializes with correct attributes' do
        expect(Unleash.logger).to_not receive(:warn)

        strategy = Unleash::ActivationStrategy.new(name, params)

        expect(strategy.name).to eq name
        expect(strategy.params).to eq params
      end
    end

    context 'with incorrect payload' do
      let!(:params) { 'bad_params' }

      it 'initializes with correct attributes and logs warning' do
        expect(Unleash.logger).to receive(:warn)

        strategy = Unleash::ActivationStrategy.new(name, params)

        expect(strategy.name).to eq name
        expect(strategy.params).to eq({})
      end
    end
  end
end
