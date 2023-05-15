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
    Unleash.logger.level = Logger::ERROR
    Unleash.toggles = []
    Unleash.toggle_metrics = {}

    # Do not test metrics:
    Unleash.configuration.disable_metrics = true
  end

  describe 'FeatureToggle with empty strategies' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "test",
        "enabled" => true,
        "strategies" => [],
        "variants" => nil
      )
    end

    it 'should return true if enabled' do
      context = Unleash::Context.new(user_id: 1)
      expect(feature_toggle.is_enabled?(context)).to be_truthy
    end
  end

  describe 'FeatureToggle with empty strategies and disabled toggle' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.userid",
        "description" => nil,
        "enabled" => false,
        "strategies" => [],
        "variants" => nil,
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    it 'should return false if disabled' do
      context = Unleash::Context.new(user_id: 1)
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end
  end

  describe 'FeatureToggle with userId strategy and enabled toggle' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.userid",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "userWithId",
            "parameters" => {
              "userIds" => "12345"
            }
          }
        ],
        "variants" => nil,
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    it 'should return true if enabled and user_id is matched' do
      context = Unleash::Context.new(user_id: "12345")
      expect(feature_toggle.is_enabled?(context)).to be_truthy
    end

    it 'should return false if enabled and user_id is unmatched' do
      context = Unleash::Context.new(user_id: "54321")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end
  end

  describe 'FeatureToggle with userId strategy and disabled toggle' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.userid",
        "description" => nil,
        "enabled" => false,
        "strategies" => [
          {
            "name" => "userWithId",
            "parameters" => {
              "userIds" => "12345"
            }
          }
        ],
        "variants" => nil,
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    it 'should return false if disabled and user_id matched' do
      context = Unleash::Context.new(user_id: "12345")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end

    it 'should return false if disabled and user_id unmatched' do
      context = Unleash::Context.new(user_id: "54321")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end
  end

  describe 'FeatureToggle with variants' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.variants",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "default"
          }
        ],
        "variants" => [
          {
            "name" => "variant1",
            "weight" => 50,
            "stickiness" => "default"
          },
          {
            "name" => "variant2",
            "weight" => 50,
            "stickiness" => "default"
          }
        ],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return variant1 for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "variant1",
        enabled: true,
        payload: nil
      )
    end

    it 'should return variant2 for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "variant2",
        enabled: true,
        payload: nil
      )
    end

    xit 'should return false if default is false.' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to be_falsey
    end
  end

  describe 'FeatureToggle including weightless variants' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.variants",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "default"
          }
        ],
        "variants" => [
          {
            "name" => "variantA",
            "weight" => 0,
            "stickiness" => "default"
          },
          {
            "name" => "variantB",
            "weight" => 10,
            "stickiness" => "default"
          },
          {
            "name" => "variantC",
            "weight" => 20,
            "stickiness" => "default"
          }
        ],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return variantC for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "variantC",
        enabled: true,
        payload: nil
      )
    end

    it 'should return variantB for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "variantB",
        enabled: true,
        payload: nil
      )
    end
  end

  describe 'FeatureToggle with variants which have all zero weight' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.variants",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "default"
          }
        ],
        "variants" => [
          {
            "name" => "variantA",
            "weight" => 0
          },
          {
            "name" => "variantB",
            "weight" => 0
          }
        ],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end
    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return disabled for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "disabled",
        enabled: false,
        payload: nil
      )
    end

    it 'should return disabled for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "disabled",
        enabled: false,
        payload: nil
      )
    end
  end

  describe 'FeatureToggle with variants that have a variant override' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.variants",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "default"
          }
        ],
        "variants" => [
          {
            "name" => "variant1",
            "weight" => 50,
            "stickiness" => "default",
            "payload" => {
              "type" => "string",
              "value" => "val1"
            },
            "overrides" => [{
              "contextName" => "userId",
              "values" => ["132", "61"]
            }]
          },
          {
            "name" => "variant2",
            "weight" => 50,
            "stickiness" => "default",
            "payload" => {
              "type" => "string",
              "value" => "val2"
            }
          }
        ],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    it 'should return variant1 for user_id:61 from override' do
      context = Unleash::Context.new(user_id: 61)
      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant1",
        enabled: true,
        payload: { "type" => "string", "value" => "val1" }
      )
    end

    it 'should return variant1 for user_id:132 from override' do
      context = Unleash::Context.new("userId" => 132)
      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant1",
        enabled: true,
        payload: { "type" => "string", "value" => "val1" }
      )
    end

    it 'should return variant2 for user_id:60' do
      context = Unleash::Context.new(user_id: 60)
      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant2",
        enabled: true,
        payload: { "type" => "string", "value" => "val2" }
      )
    end

    it 'get_variant_with_matching_override should for user_id:61' do
      # NOTE: Use send method, as we are testing a private method
      context = Unleash::Context.new(user_id: 61)
      expect(feature_toggle.send(:variant_from_override_match, context)).to have_attributes(
        name: "variant1",
        payload: { "type" => "string", "value" => "val1" }
      )
    end
  end

  describe 'FeatureToggle with no variants' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.variants",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "default"
          }
        ],
        "variants" => [],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end
    let(:default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }

    it 'should return disabled for user_id:1' do
      context = Unleash::Context.new(user_id: 10)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "disabled",
        enabled: false,
        payload: nil
      )
    end

    it 'should return disabled for user_id:2' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "disabled",
        enabled: false,
        payload: nil
      )
    end

    it 'should return an enabled fallback when the fallback is specified' do
      context = Unleash::Context.new(user_id: 2)
      expect(feature_toggle.get_variant(context, default_variant)).to have_attributes(
        name: "disabled",
        enabled: false,
        payload: nil
      )
    end
  end

  describe 'FeatureToggle with invalid default_variant' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.variants",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          {
            "name" => "default"
          }
        ],
        "variants" => [],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end
    let(:valid_default_variant) { Unleash::Variant.new(name: 'unknown', default: true) }
    let(:invalid_default_variant) { Hash.new(name: 'unknown', default: true) }

    it 'should raise an error for an invalid fallback variant' do
      expect{ feature_toggle.get_variant(nil, invalid_default_variant) }.to raise_error(ArgumentError)
    end

    it 'should not raise an error for a valid fallback variant' do
      expect{ feature_toggle.get_variant(nil, valid_default_variant) }.to_not raise_error
    end
  end

  describe 'FeatureToggle default Strategy with two constraints' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Test.userid",
        "description" => "Play with strategy constraints",
        "enabled" => true,
        "strategies" => [
          {
            "constraints" => [
              {
                "contextName" => "environment",
                "operator" => "IN",
                "values" => [
                  "dev"
                ]
              },
              {
                "contextName" => "userId",
                "operator" => "IN",
                "values" => ["123"]
              }
            ],
            "name" => "default",
            "parameters" => {
            }
          }
        ]
      )
    end

    it 'should return true if it matches all constraints' do
      context = Unleash::Context.new(user_id: "123", environment: "dev")
      expect(feature_toggle.is_enabled?(context)).to be_truthy
    end

    it 'should return false if it does not match all constraints (env)' do
      context = Unleash::Context.new(user_id: "123", environment: "prod")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end

    it 'should return false if it does not match all constraints (user_id)' do
      context = Unleash::Context.new(user_id: "11", environment: "dev")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end

    it 'should return false if it does not match any constraint (env and user_id)' do
      context = Unleash::Context.new(user_id: "11", environment: "prod")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end
  end

  describe 'FeatureToggle default Strategy with one constraint' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "Demo",
        "description" => "Play with strategy constraints",
        "enabled" => true,
        "strategies" => [
          {
            "constraints" => [
              {
                "contextName" => "environment",
                "operator" => "IN",
                "values" => [
                  "dev"
                ]
              }
            ],
            "name" => "default",
            "parameters" => {
            }
          }
        ]
      )
    end

    it 'should return true if it matches the constraint' do
      context = Unleash::Context.new(user_id: "123", environment: "dev")
      expect(feature_toggle.is_enabled?(context)).to be_truthy
    end

    it 'should return false if it does not match the constraint' do
      context = Unleash::Context.new(user_id: "123", environment: "prod")
      expect(feature_toggle.is_enabled?(context)).to be_falsey
    end
  end

  describe 'disabled_variant' do
    it 'returns disabled variant' do
      ret = described_class.disabled_variant
      expect(ret.enabled).to be false
      expect(ret.name).to eq 'disabled'
    end
  end

  describe 'FeatureToggle variant with custom stickiness' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "toggleName",
        "description" => nil,
        "enabled" => true,
        "variants" => [
          {
            "name" => "variant1",
            "weight" => 25,
            "stickiness" => "organization"
          },
          {
            "name" => "variant2",
            "weight" => 25,
            "stickiness" => "organization"
          },
          {
            "name" => "variant3",
            "weight" => 25,
            "stickiness" => "organization"
          },
          {
            "name" => "variant4",
            "weight" => 25,
            "stickiness" => "organization"
          }

        ],
        "createdAt" => "2019-01-24T10:41:45.236Z"
      )
    end

    it 'should return variant1 organization 726' do
      context = Unleash::Context.new(
        properties: {
          organization: '726'
        }
      )

      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant1",
        enabled: true
      )
    end

    it 'should return variant2 organization 48' do
      context = Unleash::Context.new(
        properties: {
          organization: '48'
        }
      )

      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant2",
        enabled: true
      )
    end

    it 'should return variant3 organization 381' do
      context = Unleash::Context.new(
        properties: {
          organization: '381'
        }
      )

      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant3",
        enabled: true
      )
    end

    it 'should return variant4 organization 222' do
      context = Unleash::Context.new(
        properties: {
          organization: '222'
        }
      )

      expect(feature_toggle.get_variant(context)).to have_attributes(
        name: "variant4",
        enabled: true
      )
    end

    it 'should work with a nil context' do
      variant = feature_toggle.get_variant(nil)

      expect(variant.name).to match(/variant\d/)
      expect(variant.enabled).to be true
      expect(variant).to be_a_kind_of(Unleash::Variant)
    end
  end

  describe 'FeatureToggle Variant with payload and custom stickiness' do
    let(:feature_toggle) do
      Unleash::FeatureToggle.new(
        "name" => "featureVariantX",
        "description" => nil,
        "enabled" => true,
        "strategies" => [
          { "name" => "default" }
        ],
        "variants" => [
          {
            "name" => "default-value",
            "payload" => {
              "type" => "string",
              "value" => "payloadData"
            },
            "stickiness" => "custom_context_attribute",
            "weight" => 100,
            "weightType" => "variable"
          }
        ]
      )
    end

    let(:expected_variant) do
      {
        name: "default-value",
        enabled: true,
        payload: {
          "type" => "string",
          "value" => "payloadData"
        }
      }
    end

    it 'should return the one variant, when the context correctly contains the custom stickiness parameter' do
      context = Unleash::Context.new(
        properties: {
          default: 'foo',
          custom_context_attribute: 'uniqueContextValue'
        }
      )
      expect(feature_toggle.get_variant(context)).to have_attributes(expected_variant)
    end

    it 'should return the one variant, with context that is nil' do
      expect(feature_toggle.get_variant(nil)).to have_attributes(expected_variant)
    end

    it 'should return the one variant, even when the contexts do not contain the stickiness parameter' do
      [
        nil,
        Unleash::Context.new,
        Unleash::Context.new(user_id: '123'),
        Unleash::Context.new(session_id: '123'),
        Unleash::Context.new(remote_address: '127.0.0.1'),
        Unleash::Context.new(properties: { not_custom_context_attribute: 'foo' })
      ].each do |context|
        expect(feature_toggle.get_variant(context)).to have_attributes(expected_variant)
      end
    end
  end
end
