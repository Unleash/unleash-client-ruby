module UnleashExtensions::OpenTelemetry
  # class ToggleFetcher < Unleash::ToggleFetcher
  module ToggleFetcher
    def fetch
      UnleashExtensions::OpenTelemetry::TRACER.in_span('Unleash::ToggleFetcher#fetch') do |_span|
        super
      end
    end

    def save!
      UnleashExtensions::OpenTelemetry::TRACER.in_span('Unleash::ToggleFetcher#save!') do |_span|
        super
      end
    end
  end
end
