require 'unleash/activation_strategy'

module Unleash
  class FeatureToggle
    attr_accessor :name, :enabled, :strategies, :choices, :choices_lock

    def initialize(params={})
      params = {} if params.nil?

      self.name = params.fetch('name', nil)
      self.enabled = params.fetch('enabled', false)

      self.strategies = params.fetch('strategies', [])
        .select{|s| ( s.key?('name') && Unleash::STRATEGIES.key?(s['name'].to_sym) ) }
        .map{|s| ActivationStrategy.new(s['name'], s['parameters'])} || []

      # Unleash.logger.debug "FeatureToggle params: #{params}"
      # Unleash.logger.debug "strategies: #{self.strategies}"
    end

    def to_s
      "<FeatureToggle: name=#{self.name},enabled=#{self.enabled},choices=#{self.choices},strategies=#{self.strategies}>"
    end

    def is_enabled?(context, default_result)
      if not ['NilClass', 'Unleash::Context'].include? context.class.name
        Unleash.logger.error "Provided context is not of the correct type #{context.class.name}, please use Unleash::Context. Context set to nil."
        context = nil
      end

      result = self.enabled && ( self.strategies.select{ |s|
        strategy = Unleash::STRATEGIES.fetch(s.name.to_sym, :unknown)
        r = strategy.is_enabled?(s.params, context)
        Unleash.logger.debug "Strategy #{s.name} returned #{r} with context: #{context}" #"for params #{s.params} "
        r
      }.any? || self.strategies.empty? )
      result ||= default_result

      Unleash.logger.debug "FeatureToggle (enabled:#{self.enabled} default_result:#{default_result} and Strategies combined returned #{result})"

      choice = result ? :yes : :no
      Unleash.toggle_metrics.increment(name, choice) unless Unleash.configuration.disable_metrics

      return result
    end

  end
end
