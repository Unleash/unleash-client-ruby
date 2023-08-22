require 'unleash/activation_strategy'
require 'unleash/constraint'
require 'unleash/variant_definition'
require 'unleash/variant'
require 'unleash/strategy/util'
require 'securerandom'

module Unleash
  class FeatureToggle
    attr_accessor :name, :enabled, :strategies, :variant_definitions

    def initialize(params = {}, segment_map = {})
      params = {} if params.nil?

      self.name       = params.fetch('name', nil)
      self.enabled    = params.fetch('enabled', false)

      self.strategies = initialize_strategies(params, segment_map)
      self.variant_definitions = initialize_variant_definitions(params)
    end

    def to_s
      "<FeatureToggle: name=#{name},enabled=#{enabled},strategies=#{strategies},variant_definitions=#{variant_definitions}>"
    end

    def is_enabled?(context)
      result = am_enabled?(context)

      choice = result ? :yes : :no
      Unleash.toggle_metrics.increment(name, choice) unless Unleash.configuration.disable_metrics

      result
    end

    def get_variant(context, fallback_variant = Unleash::FeatureToggle.disabled_variant)
      raise ArgumentError, "Provided fallback_variant is not of type Unleash::Variant" if fallback_variant.class.name != 'Unleash::Variant'

      context = ensure_valid_context(context)

      toggle_enabled = am_enabled?(context)

      variants = am_enabled(context)[:variants]

      variant = resolve_variant(context, toggle_enabled, variants)

      choice = toggle_enabled ? :yes : :no
      Unleash.toggle_metrics.increment_variant(self.name, choice, variant.name) unless Unleash.configuration.disable_metrics
      variant
    end

    def self.disabled_variant
      Unleash::Variant.new(name: 'disabled', enabled: false)
    end

    private

    def resolve_variant(context, toggle_enabled, variants)
      return Unleash::FeatureToggle.disabled_variant unless toggle_enabled
      return Unleash::FeatureToggle.disabled_variant if sum_variant_defs_weights(variants) <= 0

      variant_from_override_match(context, variants) || variant_from_weights(context, resolve_stickiness(variants), variants)
    end

    def resolve_stickiness(variants)
      variants&.map(&:stickiness)&.compact&.first || "default"
    end

    # only check if it is enabled, do not do metrics
    def am_enabled?(context)
      am_enabled(context)[:result]
    end

    def am_enabled(context)
      result = false
      variants = self.variant_definitions
      if self.enabled
        if self.strategies.empty?
          result = true
        else
          strategy = self.strategies.find(proc {false}){|s| (strategy_enabled?(s, context) && strategy_constraint_matches?(s, context))}
          if strategy
            variants = strategy.variants if strategy.variants
            result = true
          end
        end
      end

      Unleash.logger.debug "Unleash::FeatureToggle (enabled:#{self.enabled} " \
        "and Strategies combined with contraints returned #{result})"

      {
        result: result,
        variants: variants
      }
    end

    def strategy_enabled?(strategy, context)
      r = Unleash.strategies.fetch(strategy.name).is_enabled?(strategy.params, context)
      Unleash.logger.debug "Unleash::FeatureToggle.strategy_enabled? Strategy #{strategy.name} returned #{r} with context: #{context}"
      r
    end

    def strategy_constraint_matches?(strategy, context)
      return false if strategy.disabled

      strategy.constraints.empty? || strategy.constraints.all?{ |c| c.matches_context?(context) }
    end

    def sum_variant_defs_weights(variants)
      variants.map(&:weight).reduce(0, :+)
    end

    def variant_salt(context, stickiness = "default")
      begin
        return context.get_by_name(stickiness) if !context.nil? && stickiness != "default"
      rescue KeyError
        Unleash.logger.warn "Custom stickiness key (#{stickiness}) not found in the provided context #{context}. " \
          "Falling back to default behavior."
      end
      return context.user_id unless context&.user_id.to_s.empty?
      return context.session_id unless context&.session_id.to_s.empty?
      return context.remote_address unless context&.remote_address.to_s.empty?

      SecureRandom.random_number
    end

    def variant_from_override_match(context, variants)
      variant = variants.find{ |vd| vd.override_matches_context?(context) }
      return nil if variant.nil?

      Unleash::Variant.new(name: variant.name, enabled: true, payload: variant.payload)
    end

    def variant_from_weights(context, stickiness, variants)
      variant_weight = Unleash::Strategy::Util.get_normalized_number(variant_salt(context, stickiness), self.name, sum_variant_defs_weights(variants))
      prev_weights = 0

      variant_definition = variants
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

    def initialize_strategies(params, segment_map)
      params.fetch('strategies', [])
        .select{ |s| s.has_key?('name') && Unleash.strategies.includes?(s['name']) }
        .map do |s|
          ActivationStrategy.new(
            s['name'],
            s['parameters'],
            resolve_constraints(s, segment_map),
            s['variants']
          )
        end || []
    end

    def resolve_constraints(strategy, segment_map)
      segment_constraints = (strategy["segments"] || []).map do |segment_id|
        segment_map[segment_id]&.fetch("constraints")
      end
      (strategy.fetch("constraints", []) + segment_constraints).flatten.map do |constraint|
        return nil if constraint.nil?

        Constraint.new(
          constraint.fetch('contextName'),
          constraint.fetch('operator'),
          constraint.fetch('value', nil) || constraint.fetch('values', nil),
          inverted: constraint.fetch('inverted', false),
          case_insensitive: constraint.fetch('caseInsensitive', false)
        )
      end
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
