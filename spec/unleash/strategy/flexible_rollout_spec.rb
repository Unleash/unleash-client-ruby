require 'unleash/strategy/flexible_rollout'

RSpec.describe Unleash::Strategy::FlexibleRollout do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::FlexibleRollout.new }
    let(:unleash_context) { Unleash::Context.new }

    it 'should always be enabled when stickiness is default and rollout is set to 100' do
      params = {
        'groupId' => 'Demo',
        'rollout' => 100,
        'stickiness' => 'default'
      }

      expect(strategy.is_enabled?(params, unleash_context)).to be_truthy
      expect(strategy.is_enabled?(params, "invalid context")).to be_truthy
      expect(strategy.is_enabled?(params, nil)).to be_truthy
    end

    it 'should always be disabled when stickiness is default and rollout is set to 0' do
      params = {
        'groupId' => 'Demo',
        'rollout' => 0,
        'stickiness' => 'default'
      }

      expect(strategy.is_enabled?(params, unleash_context)).to be_falsey
      expect(strategy.is_enabled?(params, "invalid context")).to be_falsey
      expect(strategy.is_enabled?(params, nil)).to be_falsey
    end

    it 'should always be enabled when stickiness is random and rollout is set to 100' do
      params = {
        'groupId' => 'Demo',
        'rollout' => 100,
        'stickiness' => 'random'
      }

      expect(strategy.is_enabled?(params, unleash_context)).to be_truthy
      expect(strategy.is_enabled?(params, "invalid context")).to be_truthy
      expect(strategy.is_enabled?(params, nil)).to be_truthy
    end

    it 'should always be disabled when stickiness is random and rollout is set to 0' do
      params = {
        'groupId' => 'Demo',
        'rollout' => 0,
        'stickiness' => 'random'
      }

      expect(strategy.is_enabled?(params, unleash_context)).to be_falsey
      expect(strategy.is_enabled?(params, "invalid context")).to be_falsey
      expect(strategy.is_enabled?(params, nil)).to be_falsey
    end

    it 'should behave predictably when based on the normalized_number' do
      allow(Unleash::Strategy::Util).to receive(:get_normalized_number).and_return(15)

      params = {
        'groupId' => 'Demo',
        'stickiness' => 'default'
      }

      expect(strategy.is_enabled?(params.merge({ 'rollout' => 14 }), unleash_context)).to be_falsey
      expect(strategy.is_enabled?(params.merge({ 'rollout' => 15 }), unleash_context)).to be_truthy
      expect(strategy.is_enabled?(params.merge({ 'rollout' => 16 }), unleash_context)).to be_truthy
    end

    it 'should be enabled when stickiness=customerId and customerId=61 and rollout=10' do
      params = {
        'groupId' => 'Demo',
        'rollout' => 10,
        'stickiness' => 'customerId'
      }

      custom_context = Unleash::Context.new(
        properties: {
          customer_id: '61'
        }
      )

      expect(strategy.is_enabled?(params, custom_context)).to be_truthy
      expect(strategy.is_enabled?(params, nil)).to be_falsey
    end

    it 'should be disabled when stickiness=customerId and customerId=63 and rollout=10' do
      params = {
        'groupId' => 'Demo',
        'rollout' => 10,
        'stickiness' => 'customerId'
      }

      custom_context = Unleash::Context.new(
        properties: {
          customer_id: '63'
        }
      )

      expect(strategy.is_enabled?(params, custom_context)).to be_falsey
      expect(strategy.is_enabled?(params, nil)).to be_falsey
    end

    it 'should deviate at most one percentage point from the rollout percentage' do
      percentage = 25
      params = {
        'groupId' => 'groupId',
        'rollout' => percentage,
        'stickiness' => 'default'
      }

      rounds = 200_000
      enabled_count = 0

      rounds.times do |i|
        context = { session_id: i }

        if strategy.is_enabled?(params, context)
          enabled_count += 1
        end
      end

      actual_percentage = ((enabled_count.to_f / rounds) * 100).round
      high_mark = percentage + 1
      low_mark = percentage - 1

      expect(low_mark <= actual_percentage).to be_truthy
      expect(high_mark >= actual_percentage).to be_truthy
    end
  end
end
