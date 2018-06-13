require 'unleash/configuration'
require 'unleash/toggle_fetcher'
require 'unleash/feature_toggle'
require 'logger'

require 'awesome_print'

module Unleash

  class Client
    def initialize(*opts)
        # TODO: client library logging should be an option!
        Unleash.logger = Logger.new(STDOUT)
        Unleash.logger.level = Logger::DEBUG

        Unleash.configuration = Unleash::Configuration.new(*opts)
        Unleash.configuration.validate!

        # Unleash.logger.debug "Running configuration:"
        # ap Unleash.configuration

        Unleash.toggle_fetcher = Unleash::ToggleFetcher.new
    end

    def is_enabled?(feature, context) #*args
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} with context #{context}"

        toggle_as_hash = Unleash.toggles.select{ |toggle| toggle['name'] == feature }.first
        toggle = Unleash::FeatureToggle.new(toggle_as_hash)


        return false unless toggle.is_enabled? context

        # need to save these reports somewhere a bit more global....
        ap toggle.report
    end
  end
end
