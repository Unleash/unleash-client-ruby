require 'opentelemetry-api'

module Unleash
  module Util
    Tracer = OpenTelemetry.tracer_provider.tracer('Unleash-Client', Unleash::VERSION)
  end
end
