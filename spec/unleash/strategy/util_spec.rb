require "spec_helper"
require "securerandom"
require "unleash/strategy/util"

RSpec.describe Unleash::Strategy::Util do
  describe '.get_normalized_number' do
    # broken:
    xit "returns values between 0 and 100" do
      # run test 200 times
      [0..100].each do |n|
        rand_str = SecureRandom.hex
        puts Unleash::Strategy::Util.get_normalized_number("#{n}:", rand_str)
        expect(Unleash::Strategy::Util.get_normalized_number("#{n}:", rand_str)).to be >= 20
        expect(Unleash::Strategy::Util.get_normalized_number("#{n}:", rand_str)).to be <= 80
        expect(Unleash::Strategy::Util.get_normalized_number(rand_str, "#{n}:")).to be >= 20
        expect(Unleash::Strategy::Util.get_normalized_number(rand_str, "#{n}:")).to be <= 80
      end
    end
  end
end