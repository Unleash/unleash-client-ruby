require "spec_helper"

RSpec.describe Unleash::Strategies do
  let(:strategies) { described_class.new }

  it 'initialized with default strategies' do
    expect(strategies.keys.sort).to eq([:applicationHostname, :default, :flexibleRollout, :gradualRolloutRandom,
                                        :gradualRolloutSessionId, :gradualRolloutUserId, :remoteAddress, :userWithId])
  end

  describe '#includes?' do
    it 'returns true for available strategy' do
      expect(strategies.includes?(strategies.keys.sample)).to be_truthy
    end

    it 'returns false for missing strategy' do
      expect(strategies.includes?(:missing)).to be_falsey
    end
  end

  describe '#fetch' do
    it 'returns available strategy' do
      expect(strategies.fetch(:flexibleRollout)).to be_instance_of(Unleash::Strategy::FlexibleRollout)
    end

    it 'raising error when missing' do
      message = 'Strategy is not implemented'
      expect { strategies.fetch(:missing) }.to raise_error(Unleash::Strategy::NotImplemented, message)
    end
  end
end