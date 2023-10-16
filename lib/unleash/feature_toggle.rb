require 'unleash/activation_strategy'
require 'unleash/constraint'
require 'unleash/variant_definition'
require 'unleash/variant'
require 'unleash/strategy/util'
require 'securerandom'

module Unleash
  class FeatureToggle
    attr_accessor :name, :enabled, :dependencies, :strategies, :variant_definitions

    FeatureEvaluationResult = Struct.new(:enabled?, :strategy)

    def initialize(params = {}, segment_map = {})
      params = {} if params.nil?

      self.name       = params.fetch('name', nil)
      self.enabled    = params.fetch('enabled', false)
      self.dependencies = params.fetch('dependencies', [])

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

      evaluation_result = evaluate(context)

      group_id = evaluation_result.strategy&.params.to_h['groupId'] || self.name

      variant = resolve_variant(context, evaluation_result, group_id)

      choice = evaluation_result.enabled? ? :yes : :no
      Unleash.toggle_metrics.increment_variant(self.name, choice, variant.name) unless Unleash.configuration.disable_metrics
      variant
    end

    def self.disabled_variant
      Unleash::Variant.new(name: 'disabled', enabled: false)
    end

    private

    def resolve_variant(context, evaluation_result, group_id)
      variant_definitions = evaluation_result.strategy&.variant_definitions
      variant_definitions = self.variant_definitions if variant_definitions.nil? || variant_definitions.empty?
      return Unleash::FeatureToggle.disabled_variant unless evaluation_result.enabled?
      return Unleash::FeatureToggle.disabled_variant if sum_variant_defs_weights(variant_definitions) <= 0

      variant_from_override_match(context, variant_definitions) ||
        variant_from_weights(context, resolve_stickiness(variant_definitions), variant_definitions, group_id)
    end

    def resolve_stickiness(variant_definitions)
      variant_definitions&.map(&:stickiness)&.compact&.first || "default"
    end

    # only check if it is enabled, do not do metrics
    def am_enabled?(context)
      evaluate(context).enabled?
    end

    def parent_dependencies_satisfied?(context)
      return true if dependencies.empty?

      dependencies.all? do |parent|
        evaluate_parenthood(parent, context)
      end
    end

    def evaluate_parenthood(parent, context)
      parent_toggle = get_parent(parent["feature"])

      return false if parent_toggle.nil?

      return false unless parent_toggle.dependencies.empty?

      evaluation_result = parent_toggle.is_enabled?(context)
      if parent["enabled"] == false
        return !evaluation_result
      else
        return false unless evaluation_result
      end

      unless parent["variants"].nil? || parent["variants"].empty?
        return parent["variants"].include?(parent_toggle.get_variant(context).name)
      end
      evaluation_result
    end

    def get_parent(feature)
      toggle_as_hash = Unleash&.toggles&.select{ |toggle| toggle['name'] == feature }&.first
      if toggle_as_hash.nil?
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} not found"
        return nil
      end

      Unleash::FeatureToggle.new(toggle_as_hash, Unleash&.segment_cache)
    end

    def evaluate(context)
      evaluation_result =
        if !parent_dependencies_satisfied?(context)
          FeatureEvaluationResult.new(false, nil)
        elsif !self.enabled
          FeatureEvaluationResult.new(false, nil)
        elsif self.strategies.empty?
          FeatureEvaluationResult.new(true, nil)
        else
          strategy = self.strategies.find{ |s| strategy_enabled?(s, context) && strategy_constraint_matches?(s, context) }
          FeatureEvaluationResult.new(!strategy.nil?, strategy)
        end

      Unleash.logger.debug "Unleash::FeatureToggle (enabled:#{self.enabled}) " \
        "and Strategies combined with constraints returned #{evaluation_result})"
      evaluation_result
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

    def sum_variant_defs_weights(variant_definitions)
      variant_definitions.map(&:weight).reduce(0, :+)
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

    def variant_from_override_match(context, variant_definitions)
      variant_definition = variant_definitions.find{ |vd| vd.override_matches_context?(context) }
      return nil if variant_definition.nil?

      Unleash::Variant.new(name: variant_definition.name, enabled: true, payload: variant_definition.payload)
    end

    def variant_from_weights(context, stickiness, variant_definitions, group_id)
      variant_weight = Unleash::Strategy::Util.get_normalized_number(
        variant_salt(context, stickiness),
        group_id,
        sum_variant_defs_weights(variant_definitions)
      )
      prev_weights = 0

      variant_definition = variant_definitions
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
            resolve_variants(s)
          )
        end || []
    end

    def resolve_variants(strategy)
      strategy.fetch("variants", [])
        .select{ |variant| variant.is_a?(Hash) && variant.has_key?("name") }
        .map do |variant|
          VariantDefinition.new(
            variant.fetch("name", ""),
            variant.fetch("weight", 0),
            variant.fetch("payload", nil),
            variant.fetch("stickiness", nil),
            variant.fetch("overrides", [])
          )
        end
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
