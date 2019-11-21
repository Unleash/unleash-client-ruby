require "spec_helper"
require "unleash/strategy/remote_address"

RSpec.describe Unleash::Strategy::RemoteAddress do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::RemoteAddress.new }
    let(:unleash_context) { Unleash::Context.new({ 'remoteAddress' => '127.0.0.1' }) }

    it 'should be enabled with correct params' do
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' }, unleash_context)).to be_truthy

      unleash_context2 = Unleash::Context.new
      unleash_context2.remote_address = '172.12.0.1'
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' }, unleash_context2)).to be_truthy
    end

    it 'should be disabled with false params' do
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,172.12.0.1' }, unleash_context)).to be_falsey
    end

    it 'should be disabled on invalid params' do
      expect(strategy.is_enabled?({ 'ips' => '192.168.0.1,172.12.0.1' }, unleash_context)).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => nil }, unleash_context)).to be_falsey
      expect(strategy.is_enabled?({}, unleash_context)).to be_falsey
      expect(strategy.is_enabled?('IPs_list', unleash_context)).to be_falsey
    end

    it 'should be disabled on invalid contexts' do
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' }, Unleash::Context.new)).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' }, nil)).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' })).to be_falsey
    end
  end
end
