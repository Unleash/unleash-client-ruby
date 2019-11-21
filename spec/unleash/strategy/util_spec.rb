require "spec_helper"
require "unleash/strategy/util"

RSpec.describe Unleash::Strategy::Util do
  describe '.get_normalized_number' do
    it "returns correct values" do
      expect(Unleash::Strategy::Util.get_normalized_number('123', 'gr1')).to eq(73)
      expect(Unleash::Strategy::Util.get_normalized_number('999', 'groupX')).to eq(25)
    end
  end
end
