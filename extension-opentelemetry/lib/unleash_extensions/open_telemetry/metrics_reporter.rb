
module UnleashExtensions::OpenTelemetry
  # class MetricsReporter < Unleash::MetricsReporter
  module MetricsReporter
    def post
      UnleashExtensions::OpenTelemetry::TRACER::Tracer.in_span("#{self.class.name}##{__method__}") do |_span|
        super
      end
    end

  end
end
