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

  describe '#add' do
    let(:custom_strategy) { instance_double(Unleash::Strategy::Base, name: 'test') }

    before do
      strategies.add(custom_strategy)
    end

    it 'returns custom strategy' do
      expect(strategies.keys.sort).to eq(['applicationHostname', 'default', 'flexibleRollout', 'gradualRolloutRandom',
                                          'gradualRolloutSessionId', 'gradualRolloutUserId', 'remoteAddress',
                                          'test', 'userWithId'])
      expect(strategies.includes?('test')).to be_truthy
      expect(strategies.fetch(:test)).to eq(custom_strategy)
    end
  end
end
