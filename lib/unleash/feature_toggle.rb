require 'unleash/strategy/base'
require 'unleash/strategy/default'
require 'unleash/strategy/application_hostname'
require 'unleash/strategy/gradual_rollout_random'
require 'unleash/strategy/gradual_rollout_sessionid'
require 'unleash/strategy/gradual_rollout_userid'
require 'unleash/strategy/remote_address'
require 'unleash/strategy/user_with_id'
require 'unleash/strategy/unknown'

module Unleash
  STRATEGIES = {
    applicationHostname: Unleash::Strategy::ApplicationHostname.new,
    gradualRolloutRandom: Unleash::Strategy::GradualRolloutRandom.new,
    gradualRolloutSessionId: Unleash::Strategy::GradualRolloutSessionId.new,
    gradualRolloutUserId: Unleash::Strategy::GradualRolloutUserId.new,
    remoteAddress: Unleash::Strategy::RemoteAddress.new,
    userWithId: Unleash::Strategy::UserWithId.new,
    unknown: Unleash::Strategy::Unknown.new,
    default: Unleash::Strategy::Default.new,
  }

  class ActivationStrategy
    attr_accessor :name, :params

    def initialize(name, params = {})
      self.name = name
      if params.is_a?(Hash)
        self.params = params
      else
        Unleash.logger.warning "Invalid params provided for ActivationStrategy #{params}"
        self.params = {}
      end
    end
  end

  class FeatureToggle
    attr_accessor :name, :enabled, :strategies, :choices, :choices_lock

    def initialize(params={})
      self.name = params['name'] || nil
      self.enabled = params['enabled'] || false

      self.strategies = params['strategies']
        .select{|s| ( s.key?('name') && Unleash::STRATEGIES.key?(s['name'].to_sym) ) }
        .map{|s| ActivationStrategy.new(s['name'], s['parameters'])} || []

      # Unleash.logger.debug "FeatureToggle params: #{params}"
      # Unleash.logger.debug "strategies:"
      # ap self.strategies

      self.choices = {false => 0, true => 0}
    end

    def to_s
      "<FeatureToggle: name=#{self.name},enabled=#{self.enabled},choices=#{self.choices},strategies=#{self.strategies}>"
    end

    def is_enabled?(context = nil)
      if context.class.name != 'Unleash::Context'
        Unleash.logger.error "Provided context is not of the correct type, please use Unleash::Context"
        context = nil
      end

      result = self.enabled && self.strategies.select{ |s|
        strategy = Unleash::STRATEGIES.fetch(s.name.to_sym, :unknown)
        r = strategy.is_enabled?(s.params, context)
        Unleash.logger.debug "Strategy #{s.name} returned #{r} with context #{context}" #"for params #{s.params} "
        r
      }.any?
      Unleash.logger.debug "FeatureToggle (enabled:#{self.enabled} and Strategies combined returned #{result}"

      self.choices[result] = 0 if self.choices[result].nil?
      self.choices[result] += 1
      Unleash.logger.debug "incremented result #{result} for #{self}"
      return result
    end

    def report
      result = self.choices
      Unleash.logger.info "Feature report for #{self.name}: #{result}"
      return {'yes': result[true] || 0, 'no': result[false] || 0}
    end
  end
end