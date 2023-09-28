
module UnleashExtensions::OpenTelemetry
  # class MetricsReporter < Unleash::MetricsReporter
  module MetricsReporter
    def post
      UnleashExtensions::OpenTelemetry::TRACER::Tracer.in_span('Unleash::MetricsReporter#post') do |_span|
        super
      end
    end

  end
end
