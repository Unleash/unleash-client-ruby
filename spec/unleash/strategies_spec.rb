require "spec_helper"

RSpec.describe Unleash::Strategies do
  let(:strategies) { described_class.new }

  it 'initialized with default strategies' do
    expect(strategies.keys.sort).to eq(['applicationHostname', 'default', 'flexibleRollout', 'gradualRolloutRandom',
                                        'gradualRolloutSessionId', 'gradualRolloutUserId', 'remoteAddress',
                                        'userWithId'])
  end

  describe '#includes?' do
    it 'returns true for available strategy' do
      expect(strategies.includes?('gradualRolloutRandom')).to be_truthy
      expect(strategies.includes?(:userWithId)).to be_truthy
    end

    it 'returns false for missing strategy' do
      expect(strategies.includes?(:missing)).to be_falsey
    end
  end

  describe '#fetch' do
    it 'returns available strategy' do
      expect(strategies.fetch(:flexibleRollout)).to be_instance_of(Unleash::Strategy::FlexibleRollout)
      expect(strategies.fetch('applicationHostname')).to be_instance_of(Unleash::Strategy::ApplicationHostname)
    end

    it 'raising error when missing' do
      message = 'Strategy is not implemented'
      expect { strategies.fetch(:missing) }.to raise_error(Unleash::Strategy::NotImplemented, message)
    end
  end

  describe '#[]' do
    it 'returns available strategy' do
      expect(strategies[:flexibleRollout]).to be_instance_of(Unleash::Strategy::FlexibleRollout)
      expect(strategies['applicationHostname']).to be_instance_of(Unleash::Strategy::ApplicationHostname)
    end

    it 'returns nil when missing strategy' do
      expect(strategies[:missing]).to be_nil
    end
  end

  describe '#add' do
    before do
      strategies.add(custom_strategy)
    end

    context 'when existing strategy is available' do
      let(:custom_strategy) { instance_double(Unleash::Strategy::Base, name: 'applicationHostname') }

      it 'overrides previous strategy strategy' do
        expect(strategies.includes?('applicationHostname')).to be_truthy
        expect(strategies.fetch(:applicationHostname)).to eq(custom_strategy)
        expect(strategies.fetch('applicationHostname')).to eq(custom_strategy)
      end
    end

    context 'when strategy is new' do
      let(:custom_strategy) { instance_double(Unleash::Strategy::Base, name: 'test') }

      it 'adds new strategy strategy' do
        expect(strategies.includes?('test')).to be_truthy
        expect(strategies.fetch(:test)).to eq(custom_strategy)
        expect(strategies.fetch('test')).to eq(custom_strategy)
      end
    end
  end

  describe '#[]=' do
    let(:custom_strategy) { instance_double(Unleash::Strategy::Base, name: 'strange name') }

    context 'when existing strategy is available' do
      let(:custom_strategy) { instance_double(Unleash::Strategy::Base, name: 'applicationHostname') }

      before do
        strategies[:applicationHostname] = custom_strategy
      end

      it 'overrides previous strategy strategy' do
        expect(strategies.includes?('applicationHostname')).to be_truthy
        expect(strategies.fetch(:applicationHostname)).to eq(custom_strategy)
        expect(strategies.fetch('applicationHostname')).to eq(custom_strategy)
      end
    end

    context 'when strategy is new' do
      before do
        strategies['test'] = custom_strategy
      end

      it 'adds new strategy strategy' do
        expect(strategies.includes?('test')).to be_truthy
        expect(strategies.fetch(:test)).to eq(custom_strategy)
        expect(strategies.fetch('test')).to eq(custom_strategy)
      end
    end
  end
end
