require "spec_helper"
require "unleash/strategy/default"

RSpec.describe Unleash::Strategy::Default do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::Default.new }

    it 'always returns true' do
      expect(strategy.is_enabled?).to be_truthy
    end
  end
end
