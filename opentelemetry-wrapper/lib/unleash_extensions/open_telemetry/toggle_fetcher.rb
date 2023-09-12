require 'unleash_extensions/toggle_fetcher'
require 'util/open_telemetry'

module UnleashExtensions::OpenTelemetry
  class ToggleFetcher < Unleash::ToggleFetcher

    def fetch
      Unleash::Util::Tracer.in_span('Unleash::ToggleFetcher#fetch') do |_span|
        super
      end
    end

    def save!
      Unleash::Util::Tracer.in_span('Unleash::ToggleFetcher#save!') do |_span|
        super
      end
    end
  end
end
