require "spec_helper"
require "rspec/json_expectations"

RSpec.describe Unleash::Metrics do
  let(:metrics) { Unleash::Metrics.new }

  it "counts up correctly" do
    metrics.increment('featureA', :yes)
    metrics.increment('featureA', :yes)
    metrics.increment('featureA', :yes)
    metrics.increment('featureA', :no)
    metrics.increment('featureA', :no)

    metrics.increment('featureB', :yes)
    metrics.increment('featureB', :no)
    metrics.increment('featureC', :no)

    expect(metrics.features['featureA'][:yes]).to eq(3)
    expect(metrics.features['featureA'][:no]).to  eq(2)
    expect(metrics.features['featureB'][:yes]).to eq(1)
    expect(metrics.features['featureB'][:no]).to  eq(1)
    expect(metrics.features['featureC'][:yes]).to eq(0)
    expect(metrics.features['featureC'][:no]).to  eq(1)
  end

  it "resets correctly" do
    metrics = Unleash::Metrics.new

    metrics.increment('featureA', :yes)
    metrics.reset
    metrics.increment('featureB', :no)

    expect(metrics.features['featureA']).to be_nil
    expect(metrics.features['featureB'][:yes]).to eq(0)
    expect(metrics.features['featureB'][:no]).to eq(1)
  end

  it "spits out correct JSON" do
    metrics.reset
    metrics.increment('featureA', :yes)
    metrics.increment('featureB', :no)

    expect(metrics.to_s).to include_json(
      featureA: {
        yes: 1,
        no: 0
      },
      featureB: {
        no: 1
      }
    )
  end

  describe "when dealing with variants" do
    it "counts up correctly" do
      metrics.increment('featureA', :yes)

      metrics.increment_variant('featureA', 'variantA')
      metrics.increment_variant('featureA', 'variantA')
      metrics.increment_variant('featureA', 'variantB')

      expect(metrics.features['featureA'][:yes]).to eq(1)
      expect(metrics.features['featureA'][:no]).to eq(0)
      expect(metrics.features['featureA']['variant']['variantA']).to eq(2)
      expect(metrics.features['featureA']['variant']['variantB']).to eq(1)
    end
  end
end
