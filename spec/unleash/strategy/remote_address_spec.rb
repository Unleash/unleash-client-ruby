require "spec_helper"
require "unleash/strategy/remote_address"

RSpec.describe Unleash::Strategy::RemoteAddress do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::RemoteAddress.new }
    let(:unleash_context) { Unleash::Context.new({ 'remoteAddress' => '127.0.0.1' }) }

    def context_for_addr(remote_address)
      Unleash::Context.new(remote_address: remote_address)
    end

    it 'should be enabled with correct params' do
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' }, unleash_context)).to be_truthy

      unleash_context2 = Unleash::Context.new
      unleash_context2.remote_address = '172.12.0.1'
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,127.0.0.1,172.12.0.1' }, unleash_context2)).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => '192.168.0.1,  172.12.0.1 , 127.0.0.1' }, unleash_context2)).to be_truthy
    end

    it 'should work with ipv6' do
      ips_and_cidrs = '2001:0db8:85a3:0000:0000:8a2e:0370:7300/120,2001:0db8:85a3:0000:0000:8a2e:0370:7520/123'
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:72ff'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:7330'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:7334'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:73ff'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:7400'))).to be_falsey

      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:7519'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:7520'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:753f'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, context_for_addr('2001:0db8:85a3:0000:0000:8a2e:0370:7540'))).to be_falsey
    end

    it 'should be enabled with correct CIDR params' do
      ips_and_cidrs = '192.168.0.0/24,127.0.0.1/32,172.12.0.1'
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, unleash_context)).to be_truthy

      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '172.12.0.1'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '127.0.0.1'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '127.0.0.1/32'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '192.168.0.0'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '192.168.0.1'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '192.168.0.255'))).to be_truthy
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '192.168.0.192/30'))).to be_truthy

      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '127.0.0.2'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '192.168.1.0'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => ips_and_cidrs }, Unleash::Context.new(remote_address: '192.168.1.255'))).to be_falsey
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

      expect(strategy.is_enabled?({ 'IPs' => '192.168.x.y,127.0.0.1' }, Unleash::Context.new(remote_address: '192.168.x.y'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => 'foobar,abc/32' }, Unleash::Context.new(remote_address: 'foobar'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => 'foobar,abc/32' }, Unleash::Context.new(remote_address: '192.168.1.0'))).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => 'foobar,abc/32' }, nil)).to be_falsey
      expect(strategy.is_enabled?({ 'IPs' => 'foobar,abc/32' })).to be_falsey
    end

    it 'should be enabled for valid params even if other params are invalid' do
      expect(strategy.is_enabled?({ 'IPs' => '192.168.x.y,127.0.0.1' }, Unleash::Context.new(remote_address: '127.0.0.1'))).to be_truthy
    end
  end
end
