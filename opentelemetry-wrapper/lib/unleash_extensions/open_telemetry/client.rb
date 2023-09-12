require 'unleash/client'
require_relative './util/open_telemetry'
# require 'toggle_fetcher'
# require 'metrics_reporter'

module UnleashExtensions
  module OpenTelemetry
    class Client < Unleash::Client
      def initialize(*opts)
        Unleash::Util::Tracer.in_span('Unleash::Client#initialize') do |_span|
          super(opts)
        end
      end

      def is_enabled?(*args)
        result = super(args)

        add_trace_attributes(feature, result)
        result
      end


      def add_trace_attributes(key, variant)
        current_span = OpenTelemetry::Trace.current_span
        # OpenTelemetry::SemanticConventions::Trace::FEATURE_FLAG_* is not in the gem yet
        current_span.add_attributes({
          'feature_flag.provider_name' => 'Unleash',
          'feature_flag.key' => key,
          'feature_flag.variant' => variant
        })
      end
    end
  end
end

