require 'unleash/configuration'
require 'unleash/toggle_fetcher'
require 'unleash/metrics_reporter'
require 'unleash/scheduled_executor'
require 'unleash/feature_toggle'
require 'logger'
require 'time'

module Unleash

  class Client
    attr_accessor :fetcher_scheduled_executor, :metrics_scheduled_executor

    def initialize(*opts)
      Unleash.configuration ||= Unleash::Configuration.new(*opts)
      Unleash.configuration.validate!

      Unleash.logger = Unleash.configuration.logger.clone
      Unleash.logger.level = Unleash.configuration.log_level

      unless Unleash.configuration.disable_client
        Unleash.toggle_fetcher = Unleash::ToggleFetcher.new

        register

        self.fetcher_scheduled_executor = Unleash::ScheduledExecutor.new('ToggleFetcher', Unleash.configuration.refresh_interval)
        self.fetcher_scheduled_executor.run do
          Unleash.toggle_fetcher.fetch
        end

        unless Unleash.configuration.disable_metrics
          Unleash.toggle_metrics = Unleash::Metrics.new
          Unleash.reporter = Unleash::MetricsReporter.new
          self.metrics_scheduled_executor = Unleash::ScheduledExecutor.new('MetricsReporter', Unleash.configuration.metrics_interval)
          self.metrics_scheduled_executor.run do
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

    # enabled? is a more ruby idiomatic method name than is_enabled?
    alias_method :enabled?, :is_enabled?

    # execute a code block (passed as a parameter), if is_enabled? is true.
    def if_enabled(feature, context = nil, default_value = false, &blk)
      yield if is_enabled?(feature, context, default_value)
    end


    def get_variant(feature, context = nil, fallback_variant = false)
      Unleash.logger.debug "Unleash::Client.get_variant for feature: #{feature} with context #{context}"

      if Unleash.configuration.disable_client
        Unleash.logger.warn "unleash_client is disabled! Always returning #{default_variant} for feature #{feature}!"
        return fallback_variant || Unleash::FeatureToggle.disabled_variant
      end

      toggle_as_hash = Unleash.toggles.select{ |toggle| toggle['name'] == feature }.first if Unleash.toggles

      if toggle_as_hash.nil?
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} not found"
        return fallback_variant || Unleash::FeatureToggle.disabled_variant
      end

      toggle = Unleash::FeatureToggle.new(toggle_as_hash)
      variant = toggle.get_variant(context, fallback_variant)

      if variant.nil?
        Unleash.logger.debug "Unleash::Client.get_variant variants for feature: #{feature} not found"
        return fallback_variant || Unleash::FeatureToggle.disabled_variant
      end

      # TODO: Add to README: name, payload, enabled (bool)

      return variant
    end

    # safe shutdown: also flush metrics to server and toggles to disk
    def shutdown
      unless Unleash.configuration.disable_client
        Unleash.toggle_fetcher.save!
        Unleash.reporter.send unless Unleash.configuration.disable_metrics
        shutdown!
      end
    end

    # quick shutdown: just kill running threads
    def shutdown!
      unless Unleash.configuration.disable_client
        self.fetcher_scheduled_executor.exit
        self.metrics_scheduled_executor.exit unless Unleash.configuration.disable_metrics
      end
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
