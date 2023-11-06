# example on how to extend the unleash client with opentelemetry by monkey patching it.
# to be added before initializing the client.
# in rails it could be added, for example, at:
# config/initializers/unleash.rb

require 'opentelemetry-api'
require 'unleash'

module UnleashExtensions
  module OpenTelemetry
    TRACER = ::OpenTelemetry.tracer_provider.tracer('Unleash-Client', Unleash::VERSION)

    module Client
      def initialize(*opts)
        UnleashExtensions::OpenTelemetry::TRACER.in_span("#{self.class.name}##{__method__}") do |_span|
          super(*opts)
        end
      end

      def is_enabled?(feature, *args)
        UnleashExtensions::OpenTelemetry::TRACER.in_span("#{self.class.name}##{__method__}") do |span|
          result = super(feature, *args)

          # OpenTelemetry::SemanticConventions::Trace::FEATURE_FLAG_* is not in the `opentelemetry-semantic_conventions` gem yet
          span.add_attributes({
            'feature_flag.provider_name' => 'Unleash',
            'feature_flag.key' => feature,
            'feature_flag.variant' => result
          })

          result
        end
      end
    end
  end

  module MetricsReporter
    def post
      UnleashExtensions::OpenTelemetry::TRACER.in_span("#{self.class.name}##{__method__}") do |_span|
        super
      end
    end
  end

  module ToggleFetcher
    def fetch
      UnleashExtensions::OpenTelemetry::TRACER.in_span("#{self.class.name}##{__method__}") do |_span|
        super
      end
    end

    def save!
      UnleashExtensions::OpenTelemetry::TRACER.in_span("#{self.class.name}##{__method__}") do |_span|
        super
      end
    end
  end
end

# MonkeyPatch here:
::Unleash::Client.prepend UnleashExtensions::OpenTelemetry::Client
::Unleash::MetricsReporter.prepend UnleashExtensions::OpenTelemetry::MetricsReporter
::Unleash::ToggleFetcher.prepend UnleashExtensions::OpenTelemetry::ToggleFetcher
