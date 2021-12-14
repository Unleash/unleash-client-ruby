require 'unleash/activation_strategy'
require 'unleash/constraint'
require 'unleash/variant_definition'
require 'unleash/variant'
require 'unleash/strategy/util'
require 'securerandom'

module Unleash
  class FeatureToggle
    attr_accessor :name, :enabled, :strategies, :variant_definitions

    def initialize(params = {})
      params = {} if params.nil?

      self.name       = params.fetch('name', nil)
      self.enabled    = params.fetch('enabled', false)

      self.strategies = initialize_strategies(params)
      self.variant_definitions = initialize_variant_definitions(params)
    end

    def to_s
      "<FeatureToggle: name=#{name},enabled=#{enabled},strategies=#{strategies},variant_definitions=#{variant_definitions}>"
    end

    def is_enabled?(context, default_result)
      result = am_enabled?(context, default_result)

      choice = result ? :yes : :no
      Unleash.toggle_metrics.increment(name, choice) unless Unleash.configuration.disable_metrics

      result
    end

    def get_variant(context, fallback_variant = Unleash::FeatureToggle.disabled_variant)
      raise ArgumentError, "Provided fallback_variant is not of type Unleash::Variant" if fallback_variant.class.name != 'Unleash::Variant'

      context = ensure_valid_context(context)

      return Unleash::FeatureToggle.disabled_variant unless self.enabled && am_enabled?(context, true)
      return Unleash::FeatureToggle.disabled_variant if sum_variant_defs_weights <= 0

      variant = variant_from_override_match(context) || variant_from_weights(context, resolve_stickiness)

      Unleash.toggle_metrics.increment_variant(self.name, variant.name) unless Unleash.configuration.disable_metrics
      variant
    end

    def self.disabled_variant
      Unleash::Variant.new(name: 'disabled', enabled: false)
    end

    private

    def resolve_stickiness
      self.variant_definitions&.map(&:stickiness)&.compact&.first || "default"
    end

    # only check if it is enabled, do not do metrics
    def am_enabled?(context, default_result)
      result =
        if self.enabled
          self.strategies.empty? ||
            self.strategies.any? do |s|
              strategy_enabled?(s, context) && strategy_constraint_matches?(s, context)
            end
        else
          default_result
        end

      Unleash.logger.debug "Unleash::FeatureToggle (enabled:#{self.enabled} default_result:#{default_result} " \
        "and Strategies combined with contraints returned #{result})"

      result
    end

    def strategy_enabled?(strategy, context)
      r = Unleash::STRATEGIES.fetch(strategy.name.to_sym, :unknown).is_enabled?(strategy.params, context)
      Unleash.logger.debug "Unleash::FeatureToggle.strategy_enabled? Strategy #{strategy.name} returned #{r} with context: #{context}"
      r
    end

    def strategy_constraint_matches?(strategy, context)
      strategy.constraints.empty? || strategy.constraints.all?{ |c| c.matches_context?(context) }
    end

    def sum_variant_defs_weights
      self.variant_definitions.map(&:weight).reduce(0, :+)
    end

    def variant_salt(context, stickiness = "default")
      return context.get_by_name(stickiness) unless stickiness == "default"
      return context.user_id unless context.user_id.to_s.empty?
      return context.session_id unless context.session_id.to_s.empty?
      return context.remote_address unless context.remote_address.to_s.empty?

      SecureRandom.random_number
    end

    def variant_from_override_match(context)
      variant = self.variant_definitions.find{ |vd| vd.override_matches_context?(context) }
      return nil if variant.nil?

      Unleash::Variant.new(name: variant.name, enabled: true, payload: variant.payload)
    end

    def variant_from_weights(context, stickiness)
      variant_weight = Unleash::Strategy::Util.get_normalized_number(variant_salt(context, stickiness), self.name, sum_variant_defs_weights)
      prev_weights = 0

      variant_definition = self.variant_definitions
        .find do |v|
          res = (prev_weights + v.weight >= variant_weight)
          prev_weights += v.weight
          res
        end
      return self.disabled_variant if variant_definition.nil?

      Unleash::Variant.new(name: variant_definition.name, enabled: true, payload: variant_definition.payload)
    end

    def ensure_valid_context(context)
      unless ['NilClass', 'Unleash::Context'].include? context.class.name
        Unleash.logger.error "Provided context is not of the correct type #{context.class.name}, " \
          "please use Unleash::Context. Context set to nil."
        context = nil
      end
      context
    end

    def initialize_strategies(params)
      params.fetch('strategies', [])
        .select{ |s| s.has_key?('name') && Unleash::STRATEGIES.has_key?(s['name'].to_sym) }
        .map do |s|
          ActivationStrategy.new(
            s['name'],
            s['parameters'],
            (s['constraints'] || []).map do |c|
              Constraint.new(
                c.fetch('contextName'),
                c.fetch('operator'),
                c.fetch('values')
              )
            end
          )
        end || []
    end

    def initialize_variant_definitions(params)
      (params.fetch('variants', []) || [])
        .select{ |v| v.is_a?(Hash) && v.has_key?('name') }
        .map do |v|
          VariantDefinition.new(
            v.fetch('name', ''),
            v.fetch('weight', 0),
            v.fetch('payload', nil),
            v.fetch('stickiness', nil),
            v.fetch('overrides', [])
          )
        end || []
    end
  end
end
