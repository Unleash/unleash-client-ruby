require 'unleash'
require_relative 'open_telemetry/ons/open_telemetry/client'
require 'open_telemetry/metrics_reporter'
require 'open_telemetry/toggle_fetcher'

module UnleashExtensions
  module OpenTelemetry
    extend Unleash
  end
end

# MonkeyPatch here:
Unleash.include UnleashExtensions::OpenTelemetry
