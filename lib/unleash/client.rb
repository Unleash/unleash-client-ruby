require 'unleash/configuration'
require 'unleash/toggle_fetcher'
require 'unleash/metrics_reporter'
require 'unleash/scheduled_executor'
require 'unleash/feature_toggle'
require 'unleash/util/http'
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

      Unleash.toggle_fetcher = Unleash::ToggleFetcher.new
      if Unleash.configuration.disable_client
        Unleash.logger.warn "Unleash::Client is disabled! Will only return default (or bootstrapped if available) results!"
        return
      end

      register
      start_toggle_fetcher
      start_metrics unless Unleash.configuration.disable_metrics
    end

    def is_enabled?(feature, context = nil, default_value_param = false, &fallback_blk)
      Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} with context #{context}"

      default_value = if block_given?
                        default_value_param || !!fallback_blk.call(feature, context)
                      else
                        default_value_param
                      end

      toggle_as_hash = Unleash&.toggles&.select{ |toggle| toggle['name'] == feature }&.first

      if toggle_as_hash.nil?
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} not found"
        return default_value
      end

      toggle = Unleash::FeatureToggle.new(toggle_as_hash)

      toggle.is_enabled?(context, default_value)
    end

    # enabled? is a more ruby idiomatic method name than is_enabled?
    alias enabled? is_enabled?

    # execute a code block (passed as a parameter), if is_enabled? is true.
    def if_enabled(feature, context = nil, default_value = false, &blk)
      yield(blk) if is_enabled?(feature, context, default_value)
    end

    def get_variant(feature, context = Unleash::Context.new, fallback_variant = disabled_variant)
      Unleash.logger.debug "Unleash::Client.get_variant for feature: #{feature} with context #{context}"

      if Unleash.configuration.disable_client
        Unleash.logger.debug "unleash_client is disabled! Always returning #{fallback_variant} for feature #{feature}!"
        return fallback_variant
      end

      toggle_as_hash = Unleash&.toggles&.select{ |toggle| toggle['name'] == feature }&.first

      if toggle_as_hash.nil?
        Unleash.logger.debug "Unleash::Client.get_variant feature: #{feature} not found"
        return fallback_variant
      end

      toggle = Unleash::FeatureToggle.new(toggle_as_hash)
      variant = toggle.get_variant(context, fallback_variant)

      if variant.nil?
        Unleash.logger.debug "Unleash::Client.get_variant variants for feature: #{feature} not found"
        return fallback_variant
      end

      # TODO: Add to README: name, payload, enabled (bool)

      variant
    end

    # safe shutdown: also flush metrics to server and toggles to disk
    def shutdown
      unless Unleash.configuration.disable_client
        Unleash.toggle_fetcher.save!
        Unleash.reporter.post unless Unleash.configuration.disable_metrics
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
      {
        'appName': Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'sdkVersion': "unleash-client-ruby:" + Unleash::VERSION,
        'strategies': Unleash::STRATEGIES.keys,
        'started': Time.now.iso8601(Unleash::TIME_RESOLUTION),
        'interval': Unleash.configuration.metrics_interval_in_millis
      }
    end

    def start_toggle_fetcher
      self.fetcher_scheduled_executor = Unleash::ScheduledExecutor.new(
        'ToggleFetcher',
        Unleash.configuration.refresh_interval,
        Unleash.configuration.retry_limit,
        first_fetch_is_eager
      )
      self.fetcher_scheduled_executor.run do
        Unleash.toggle_fetcher.fetch
      end
    end

    def start_metrics
      Unleash.toggle_metrics = Unleash::Metrics.new
      Unleash.reporter = Unleash::MetricsReporter.new
      self.metrics_scheduled_executor = Unleash::ScheduledExecutor.new(
        'MetricsReporter',
        Unleash.configuration.metrics_interval,
        Unleash.configuration.retry_limit
      )
      self.metrics_scheduled_executor.run do
        Unleash.reporter.post
      end
    end

    def register
      Unleash.logger.debug "register()"

      # Send the request, if possible
      begin
        response = Unleash::Util::Http.post(Unleash.configuration.client_register_uri, info.to_json)
      rescue StandardError => e
        Unleash.logger.error "unable to register client with unleash server due to exception #{e.class}:'#{e}'."
        Unleash.logger.error "stacktrace: #{e.backtrace}"
      end
      Unleash.logger.debug "client registered: #{response}"
    end

    def disabled_variant
      @disabled_variant ||= Unleash::FeatureToggle.disabled_variant
    end

    def first_fetch_is_eager
      Unleash.configuration.use_bootstrap?
    end
  end
end
