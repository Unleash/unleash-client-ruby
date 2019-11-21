require "spec_helper"
require "unleash/strategy/gradual_rollout_userid"

RSpec.describe Unleash::Strategy::GradualRolloutUserId do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::GradualRolloutUserId.new }
    let(:unleash_context) { Unleash::Context.new({ 'userId' => 'alice' }) }
    let(:percentage) { Unleash::Strategy::Util.get_normalized_number(unleash_context.user_id, "") }

    it 'return true when percentage set is gt the number returned by the hash function' do
      expect(strategy.is_enabled?({ 'percentage' => (percentage + 1).to_s }, unleash_context)).to be_truthy
      expect(strategy.is_enabled?({ 'percentage' => percentage + 1 },   unleash_context)).to be_truthy
      expect(strategy.is_enabled?({ 'percentage' => percentage + 0.1 }, unleash_context)).to be_truthy
    end

    it 'return false when percentage set is lt the number returned by the hash function' do
      expect(strategy.is_enabled?({ 'percentage' => (percentage - 1).to_s }, unleash_context)).to be_falsey
      expect(strategy.is_enabled?({ 'percentage' => percentage - 1 },   unleash_context)).to be_falsey
      expect(strategy.is_enabled?({ 'percentage' => percentage - 0.1 }, unleash_context)).to be_falsey
    end
  end
end
