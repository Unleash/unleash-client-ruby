require "spec_helper"
require "unleash/strategy/application_hostname"

RSpec.describe Unleash::Strategy::ApplicationHostname do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::ApplicationHostname.new }

    before do
      expect(Socket).to receive(:gethostname).and_return("rspechost")
    end

    it 'correctly initialize' do
      expect(strategy.hostname).to eq("rspechost")
    end

    it 'should be enabled with correct params' do
      expect(strategy.is_enabled?({ 'hostnames' => 'foo,rspechost,bar' })).to be_truthy
    end

    it 'should be disabled with false params' do
      expect(strategy.is_enabled?({ 'hostnames' => 'abc,localhost' })).to be_falsey
    end

    it 'should be disabled on invalid params' do
      expect(strategy.is_enabled?(nil)).to be_falsey
      expect(strategy.is_enabled?('string')).to be_falsey
      expect(strategy.is_enabled?({})).to be_falsey
    end
  end
end
