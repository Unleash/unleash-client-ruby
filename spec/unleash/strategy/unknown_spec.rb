require "spec_helper"
require "unleash/strategy/unknown"

RSpec.describe Unleash::Strategy::Unknown do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::Unknown.new }

    it 'always return false' do
      expect(strategy.is_enabled?()).to be_falsey
    end
  end
end