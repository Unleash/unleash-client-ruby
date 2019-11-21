require "spec_helper"
require "unleash/strategy/base"

RSpec.describe Unleash::Strategy::Base do
  describe '#is_enabled?' do
    let(:strategy) { Unleash::Strategy::Base.new }

    it 'raise exception' do
      expect{ strategy.is_enabled? }.to raise_exception Unleash::Strategy::NotImplemented
    end
  end
end
