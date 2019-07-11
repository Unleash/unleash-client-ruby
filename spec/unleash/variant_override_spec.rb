require 'spec_helper'

RSpec.describe Unleash::VariantOverride do
  context 'parameters correctly assigned in initialization'

  it 'should raise exception if instanciated with invalid parameters' do
    expect{ Unleash::VariantOverride.new(name: 'userId', values: ['123', '61']) }.to raise_error(ArgumentError)
  end

  describe 'Simple VariantOverride with userId parameter set' do
    let(:variant_override) { Unleash::VariantOverride.new('userId', ['123', '61']) }

    it 'matching context should return true' do
      context = Unleash::Context.new(user_id: '61')
      expect(variant_override.matches_context?(context)).to be true
    end

    it 'matching context should return true' do
      context = Unleash::Context.new(user_id: '123')
      expect(variant_override.matches_context?(context)).to be true
    end

    it 'NOT matching context should return false' do
      context = Unleash::Context.new(user_id: '0')
      expect(variant_override.matches_context?(context)).to be false
    end
  end
end
