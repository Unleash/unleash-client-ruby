require 'unleash_extensions/metrics_reporter'
require 'util/open_telemetry'

module UnleashExtensions::OpenTelemetry
  class MetricsReporter < Unleash::MetricsReporter
    def post
      Unleash::Util::Tracer.in_span('Unleash::MetricsReporter#post') do |_span|
        super
      end
    end


  end
end
