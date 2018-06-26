require 'unleash/configuration'
require 'unleash/toggle_fetcher'
require 'unleash/metrics_reporter'
require 'unleash/feature_toggle'
require 'logger'
require 'time'

module Unleash

  class Client
    def initialize(*opts)
      Unleash.configuration ||= Unleash::Configuration.new(*opts)
      Unleash.configuration.validate!

      Unleash.logger = Unleash.configuration.logger
      Unleash.logger.level = Unleash.configuration.log_level

      Unleash.toggle_fetcher = Unleash::ToggleFetcher.new

      unless Unleash.configuration.disable_metrics
        Unleash.toggle_metrics = Unleash::Metrics.new
        Unleash.reporter = Unleash::MetricsReporter.new
        scheduledExecutor = Unleash::ScheduledExecutor.new('MetricsReporter', Unleash.configuration.metrics_interval)
        scheduledExecutor.run do
          Unleash.reporter.send
        end
      end
      register
    end

    def is_enabled?(feature, context = nil, default_value = false)
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} with context #{context}"

        toggle_as_hash = Unleash.toggles.select{ |toggle| toggle['name'] == feature }.first

        if toggle_as_hash.nil?
          Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} not found"
          return default_value
        end

        toggle = Unleash::FeatureToggle.new(toggle_as_hash)
        toggle_result = toggle.is_enabled?(context, default_value)

        return toggle_result
    end

    private
    def info
      return {
        'appName':  Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'sdkVersion': "unleash-client-ruby:" + Unleash::VERSION,
        'strategies': Unleash::STRATEGIES.keys,
        'started': Time.now.iso8601(Unleash::TIME_RESOLUTION),
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

      # Send the request
      response = http.request(request)
    end
  end
end
