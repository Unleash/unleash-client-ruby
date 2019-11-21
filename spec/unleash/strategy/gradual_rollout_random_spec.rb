require "spec_helper"
require "unleash/strategy/gradual_rollout_random"

RSpec.describe Unleash::Strategy::GradualRolloutRandom do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::GradualRolloutRandom.new }

    before do
      # Random.rand always returns 15, so it is not really random in our tests.
      allow(Random).to receive(:rand).and_return(15)
    end

    it 'return true when percentage set (20) is over the returned random value (15)' do
      expect(strategy.is_enabled?({ 'percentage' => '20' })).to be_truthy
      expect(strategy.is_enabled?({ 'percentage' => 20 })).to   be_truthy
      expect(strategy.is_enabled?({ 'percentage' => 20.0 })).to be_truthy
    end

    it 'return false when percentage set (10) is under the returned random value (15)' do
      expect(strategy.is_enabled?({ 'percentage' => '10' })).to be_falsey
      expect(strategy.is_enabled?({ 'percentage' => 10 })).to   be_falsey
      expect(strategy.is_enabled?({ 'percentage' => 10.0 })).to be_falsey
    end

    it 'return false when percentage is invalid' do
      expect(strategy.is_enabled?({ 'percentage' => -1 })).to be_falsey
      expect(strategy.is_enabled?({ 'percentage' => nil })).to be_falsey
      expect(strategy.is_enabled?({ 'percentage' => 'abc' })).to be_falsey
      expect(strategy.is_enabled?('text')).to be_falsey
      expect(strategy.is_enabled?(nil)).to be_falsey
    end
  end
end
