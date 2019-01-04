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

      unless Unleash.configuration.disable_client
        Unleash.toggle_fetcher = Unleash::ToggleFetcher.new
        register

        unless Unleash.configuration.disable_metrics
          Unleash.toggle_metrics = Unleash::Metrics.new
          Unleash.reporter = Unleash::MetricsReporter.new
          scheduledExecutor = Unleash::ScheduledExecutor.new('MetricsReporter', Unleash.configuration.metrics_interval)
          scheduledExecutor.run do
            Unleash.reporter.send
          end
        end
      else
        Unleash.logger.warn "Unleash::Client is disabled! Will only return default results!"
      end
    end

    def is_enabled?(feature, context = nil, default_value = false)
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} with context #{context}"

        if Unleash.configuration.disable_client
          Unleash.logger.warn "unleash_client is disabled! Always returning #{default_value} for feature #{feature}!"
          return default_value
        end

        toggle_as_hash = Unleash.toggles.select{ |toggle| toggle['name'] == feature }.first if Unleash.toggles

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
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = Unleash.configuration.timeout # in seconds
      http.read_timeout = Unleash.configuration.timeout # in seconds

      headers = (Unleash.configuration.get_http_headers || {}).dup
      headers['Content-Type'] = 'application/json'

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = info.to_json

      # Send the request, if possible
      begin
        response = http.request(request)
      rescue Exception => e
        Unleash.logger.error "unable to register client with unleash server due to exception #{e.class}:'#{e}'."
        Unleash.logger.error "stacktrace: #{e.backtrace}"
      end
    end
  end
end
