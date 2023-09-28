require 'opentelemetry-api'
require 'unleash'

require 'unleash_extensions/open_telemetry/client'
require 'unleash_extensions/open_telemetry/metrics_reporter'
require 'unleash_extensions/open_telemetry/toggle_fetcher'

module UnleashExtensions
  module OpenTelemetry
    TRACER = ::OpenTelemetry.tracer_provider.tracer('Unleash-Client', Unleash::VERSION)
  end
end

# MonkeyPatch here:
::Unleash::Client.prepend UnleashExtensions::OpenTelemetry::Client
::Unleash::MetricsReporter.prepend UnleashExtensions::OpenTelemetry::MetricsReporter
::Unleash::ToggleFetcher.prepend UnleashExtensions::OpenTelemetry::ToggleFetcher
