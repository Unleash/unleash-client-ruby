require "unleash/strategy/user_with_id"
require "unleash/context"

RSpec.describe Unleash::Strategy::UserWithId do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::UserWithId.new }

    context 'with string params' do
      let(:unleash_context) { Unleash::Context.new({ 'userId' => 'bob' }) }

      it 'should be enabled with correct params' do
        expect(strategy.is_enabled?({ 'userIds' => 'alice,bob,carol,dave' }, unleash_context)).to be_truthy

        unleash_context2 = Unleash::Context.new
        unleash_context2.user_id = 'alice'
        expect(strategy.is_enabled?({ 'userIds' => 'alice,bob,carol,dave' }, unleash_context2)).to be_truthy
      end

      it 'should be enabled with correct can include spaces' do
        expect(strategy.is_enabled?({ 'userIds' => ' alice ,bob,carol,dave' }, unleash_context)).to be_truthy
      end

      it 'should be disabled with false params' do
        expect(strategy.is_enabled?({ 'userIds' => 'alice,dave' }, unleash_context)).to be_falsey
      end

      it 'should be disabled on invalid params' do
        expect(strategy.is_enabled?({ 'userIds' => nil }, unleash_context)).to be_falsey
        expect(strategy.is_enabled?({}, unleash_context)).to be_falsey
        expect(strategy.is_enabled?('string', unleash_context)).to be_falsey
        expect(strategy.is_enabled?(nil, unleash_context)).to be_falsey
      end

      it 'should be disabled on invalid contexts' do
        expect(strategy.is_enabled?({ 'userIds' => 'alice,bob,carol,dave' }, Unleash::Context.new)).to be_falsey
        expect(strategy.is_enabled?({ 'userIds' => 'alice,bob,carol,dave' }, nil)).to be_falsey
        expect(strategy.is_enabled?({ 'userIds' => 'alice,bob,carol,dave' })).to be_falsey
      end
    end

    context 'with int params' do
      let(:user_id) { 123 }
      let(:unleash_context) { Unleash::Context.new({ 'userId' => user_id }) }

      it 'should be enabled with correct params' do
        expect(strategy.is_enabled?({ 'userIds' => '1,2,123' }, unleash_context)).to be_truthy

        unleash_context2 = Unleash::Context.new(user_id: 1)
        expect(strategy.is_enabled?({ 'userIds' => '1,2,123' }, unleash_context2)).to be_truthy
      end

      it 'should be enabled with correct can include spaces' do
        expect(strategy.is_enabled?({ 'userIds' => ' 1 ,2, 123 ,200 ' }, unleash_context)).to be_truthy
      end

      it 'should be disabled with false params' do
        expect(strategy.is_enabled?({ 'userIds' => '1,2' }, unleash_context)).to be_falsey
      end
    end
  end
end
