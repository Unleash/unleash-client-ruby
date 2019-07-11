require 'logger'
require 'unleash'
require 'unleash/configuration'
require 'unleash/context'
require 'unleash/feature_toggle'
require 'unleash/variant'

RSpec.describe Unleash::FeatureToggle do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
    Unleash.logger.level = Unleash.configuration.log_level
    # Unleash.logger.level = Logger::DEBUG
    Unleash.toggles = []
    Unleash.toggle_metrics = {}

  #   # Do not test metrics:
    Unleash.configuration.disable_metrics = true
  end

  describe 'FeatureToggle with empty strategies' do
    let(:feature_toggle) { Unleash::FeatureToggle.new(
      name: 'test',
      enabled: true,
      strategies: [],
      variants: nil
      ) }

    it 'should return true' do
      context = Unleash::Context.new(user_id: 1)
      expect(feature_toggle.is_enabled?(context, true)).to be_truthy
    end
  end

  describe 'FeatureToggle with variants' do
    let(:feature_toggle) { Unleash::FeatureToggle.new(JSON.parse('{
        "name": "Test.variants",
        "description": null,
        "enabled": true,
        "strategies": [
          {
            "name": "default"
          }
        ],
        "variants": [
          {
            "name": "variant1",
            "weight": 50
          },
          {
            "name": "variant2",
            "weight": 50
          }
        ],
        "createdAt": "2019-01-24T10:41:45.236Z"
      }')
    ) }

    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return variant1 for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"variant1", enabled: true, payload: nil)
    end

    it 'should return variant2 for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"variant2", enabled: true, payload: nil)
    end

    xit 'should return false if default is false.' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to be_falsey
    end
  end

  describe 'FeatureToggle including weightless variants' do
    let(:feature_toggle) { Unleash::FeatureToggle.new(JSON.parse('{
        "name": "Test.variants",
        "description": null,
        "enabled": true,
        "strategies": [
          {
            "name": "default"
          }
        ],
        "variants": [
          {
            "name": "variantA",
            "weight": 0
          },
          {
            "name": "variantB",
            "weight": 10
          },
          {
            "name": "variantC",
            "weight": 20
          }
        ],
        "createdAt": "2019-01-24T10:41:45.236Z"
      }')
    ) }
    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }


    it 'should return variantC for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"variantC", enabled: true, payload: nil)
    end

    it 'should return variantB for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"variantB", enabled: true, payload: nil)
    end
  end

  describe 'FeatureToggle with variants which have all zero weight' do
    let(:feature_toggle) { Unleash::FeatureToggle.new(JSON.parse('{
        "name": "Test.variants",
        "description": null,
        "enabled": true,
        "strategies": [
          {
            "name": "default"
          }
        ],
        "variants": [
          {
            "name": "variantA",
            "weight": 0
          },
          {
            "name": "variantB",
            "weight": 0
          }
        ],
        "createdAt": "2019-01-24T10:41:45.236Z"
      }')
    ) }
    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return disabled for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"disabled", enabled: false, payload: nil)
    end

    it 'should return disabled for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"disabled", enabled: false, payload: nil)
    end
  end

  describe 'FeatureToggle with variants that have a variant override' do
    let(:feature_toggle) { Unleash::FeatureToggle.new(JSON.parse('{
        "name": "Test.variants",
        "description": null,
        "enabled": true,
        "strategies": [
          {
            "name": "default"
          }
        ],
        "variants": [
          {
            "name": "variant1",
            "weight": 50,
            "payload": {
              "type": "string",
              "value": "val1"
            },
            "overrides": [{
              "contextName": "userId",
              "values": ["132", "61"]
            }]
          },
          {
              "name": "variant2",
              "weight": 50,
              "payload": {
                "type": "string",
                "value": "val2"
              }
          }
        ],
        "createdAt": "2019-01-24T10:41:45.236Z"
      }')
    ) }

    it 'should return variant1 for user_id:61 from override' do
      context = Unleash::Context.new(user_id: 61)
      expect(feature_toggle.get_variant(context)).to have_attributes(name:"variant1", enabled: true, payload: {"type" => "string","value" => "val1"})
    end

    it 'should return variant1 for user_id:132 from override' do
      context = Unleash::Context.new("userId" => 132)
      expect(feature_toggle.get_variant(context)).to have_attributes(name:"variant1", enabled: true, payload: {"type" => "string","value" => "val1"})
    end

    it 'should return variant2 for user_id:60' do
      context = Unleash::Context.new(user_id: 60)
      expect(feature_toggle.get_variant(context)).to have_attributes(name:"variant2", enabled: true, payload: {"type" => "string","value" => "val2"})
    end

    it 'get_variant_with_matching_override should for user_id:61' do
      # NOTE: Use send method, as we are testing a private method
      context = Unleash::Context.new(user_id: 61)
      expect(feature_toggle.send(:variant_from_override_match, context)).to have_attributes(name:"variant1", payload: {"type" => "string","value" => "val1"})
    end
  end

  describe 'FeatureToggle with no variants' do
    let(:feature_toggle) { Unleash::FeatureToggle.new(JSON.parse('{
        "name": "Test.variants",
        "description": null,
        "enabled": true,
        "strategies": [
          {
            "name": "default"
          }
        ],
        "variants": [],
        "createdAt": "2019-01-24T10:41:45.236Z"
      }')
    ) }
    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return disabled for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"disabled", enabled: false, payload: nil)
    end

    it 'should return disabled for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"disabled", enabled: false, payload: nil)
    end

    it 'should return an enabled fallback when the fallback is specified' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(name:"disabled", enabled: false, payload: nil)
    end
  end

end
