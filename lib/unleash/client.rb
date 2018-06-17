require 'unleash/configuration'
require 'unleash/toggle_fetcher'
require 'unleash/reporter'
require 'unleash/feature_toggle'
require 'logger'
require 'time'

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

      unless Unleash.configuration.disable_metrics
        Unleash.toggle_metrics = Unleash::Metrics.new
        Unleash.reporter = Unleash::Reporter.new
      end
      register
    end

    def is_enabled?(feature, context, default_value = false)
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} with context #{context}"

        toggle_as_hash = Unleash.toggles.select{ |toggle| toggle['name'] == feature }.first

        if toggle_as_hash.nil?
          Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} not found"
          return default_value
        end


        toggle = Unleash::FeatureToggle.new(toggle_as_hash)


        toggle_is_enabled = toggle.is_enabled?(context) || default_value

        # need to save these reports somewhere a bit more global...
        Unleash.logger.debug "Unleash::Client.is_enabled?  report:"
        ap Unleash.toggle_metrics


        Unleash.reporter.send
        return toggle_is_enabled
    end

    private
    def info
      return {
        'appName':  Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'sdkVersion': "unleash-client-ruby:" + Unleash::VERSION,
        'strategies': Unleash::STRATEGIES.keys,
        'started': Time.now.iso8601,
        'interval': Unleash.configuration.metrics_interval_in_millis
      }
    end

    def register
      Unleash.logger.debug "register()"

      uri = URI(Unleash.configuration.client_register_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = Unleash.configuration.timeout # in seconds
      http.read_timeout = Unleash.configuration.timeout # in seconds
      headers = {'Content-Type' => 'application/json'}
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = info.to_json

      ap request.body

      # Send the request
      response = http.request(request)
    end
  end
end
