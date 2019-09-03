require 'unleash/activation_strategy'
require 'unleash/variant_definition'
require 'unleash/variant'
require 'unleash/strategy/util'
require 'securerandom'

module Unleash
  class FeatureToggle
    attr_accessor :name, :enabled, :strategies, :variant_definitions

    def initialize(params={})
      params = {} if params.nil?

      self.name = params.fetch('name', nil)
      self.enabled = params.fetch('enabled', false)

      self.strategies = params.fetch('strategies', [])
        .select{ |s| ( s.key?('name') && Unleash::STRATEGIES.key?(s['name'].to_sym) ) }
        .map{ |s| ActivationStrategy.new(s['name'], s['parameters'] || {}) } || []

      self.variant_definitions = (params.fetch('variants', []) || [])
        .select{ |v| v.is_a?(Hash) && v.key?('name') }
        .map{ |v|
          VariantDefinition.new(
            v.fetch('name', ''),
            v.fetch('weight', 0),
            v.fetch('payload', nil),
            v.fetch('overrides', [])
          )
        } || []
    end

    def to_s
      "<FeatureToggle: name=#{self.name},enabled=#{self.enabled},strategies=#{self.strategies},variant_definitions=#{self.variant_definitions}>"
    end

    def is_enabled?(context, default_result)
      unless ['NilClass', 'Unleash::Context'].include? context.class.name
        Unleash.logger.error "Provided context is not of the correct type #{context.class.name}, please use Unleash::Context. Context set to nil."
        context = nil
      end

      result = am_enabled?(context, default_result)

      choice = result ? :yes : :no
      Unleash.toggle_metrics.increment(name, choice) unless Unleash.configuration.disable_metrics

      return result
    end

    def get_variant(context, fallback_variant = disabled_variant)
      unless ['NilClass', 'Unleash::Context'].include? context.class.name
        Unleash.logger.error "Provided context is not of the correct type #{context.class.name}, please use Unleash::Context. Context set to nil."
        context = nil
      end

      unless ['Unleash::Variant'].include? fallback_variant.class.name
        raise ArgumentError, "Provided fallback_variant is not of the correct type #{fallback_variant.class.name}, please use Unleash::Variant."
      end

      return disabled_variant unless self.enabled && am_enabled?(context, true)
      return disabled_variant if get_sum_variant_defs_weights <= 0

      variant = variant_from_override_match(context)
      variant = variant_from_weights(context) if variant.nil?

      Unleash.toggle_metrics.increment_variant(self.name, variant.name) unless Unleash.configuration.disable_metrics
      return variant
    end

    private

    # only check if it is enabled, do not do metrics
    def am_enabled?(context, default_result)
      strategy_result = ( self.strategies.select{ |s|
        strategy = Unleash::STRATEGIES.fetch(s.name.to_sym, :unknown)
        r = strategy.is_enabled?(s.params, context)
        Unleash.logger.debug "Strategy #{s.name} returned #{r} with context: #{context}" #"for params #{s.params} "
        r
      }.any? || self.strategies.empty? )
      result = self.enabled ? strategy_result : default_result

      Unleash.logger.debug "FeatureToggle (enabled:#{self.enabled} default_result:#{default_result} and Strategies combined returned #{result})"
      return result
    end

    def disabled_variant
      Unleash::Variant.new(name: 'disabled', enabled: false)
    end

    def get_sum_variant_defs_weights
      self.variant_definitions.map{ |v| v.weight }.reduce(0, :+)
    end

    def variant_salt(context)
      return context.user_id unless context.user_id.to_s.empty?
      return context.session_id unless context.session_id.to_s.empty?
      return context.remote_address unless context.remote_address.to_s.empty?
      return SecureRandom.random_number
    end

    def variant_from_override_match(context)
      variant = self.variant_definitions.select{ |vd| vd.override_matches_context?(context) }.first

      return nil if variant.nil?
      Unleash::Variant.new(name: variant.name, enabled: true, payload: variant.payload)
    end

    def variant_from_weights(context)
      variant_weight = Unleash::Strategy::Util.get_normalized_number(variant_salt(context), self.name, get_sum_variant_defs_weights())
      prev_weights = 0

      variant_definition = self.variant_definitions
        .select{ |v|
          res = (prev_weights + v.weight >= variant_weight)
          prev_weights += v.weight
          res
        }
        .first
      return disabled_variant if variant_definition.nil?

      Unleash::Variant.new(name: variant_definition.name, enabled: true, payload: variant_definition.payload)
    end
  end
end
