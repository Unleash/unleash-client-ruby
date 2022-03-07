require 'unleash/util/http'
require 'unleash/context'

module Unleash
  module Proxy
    class Client
      attr_accessor \
        :proxy_url,
        :proxy_custom_http_headers,
        :toggles

      def initialize(opts)
        self.proxy_url = opts.delete(:proxy_url)
        self.proxy_custom_http_headers = opts.delete(:proxy_custom_http_headers)

        Unleash.configuration ||= Unleash::Configuration.new(*opts)

        default_logger = Logger.new(STDOUT)
        Unleash.logger = opts.fetch(:logger, nil) || default_logger
        # Unleash.logger.level = opts.fetch(:log_level, Logger::WARN)
      end

      def is_enabled?(feature, context = nil, default_value_param = false, &fallback_blk)
        Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} with context #{context}"

        retrieve_toggles(context)

        default_value = if block_given?
                          default_value_param || !!fallback_blk.call(feature, context)
                        else
                          default_value_param
                        end

        toggle_as_hash = self.toggles.select{ |toggle| toggle['name'] == feature }&.first

        if toggle_as_hash.nil?
          Unleash.logger.debug "Unleash::Client.is_enabled? feature: #{feature} not found"
          return default_value
        end

        !!toggle_as_hash['enabled']
      end

      # enabled? is a more ruby idiomatic method name than is_enabled?
      alias enabled? is_enabled?

      # execute a code block (passed as a parameter), if is_enabled? is true.
      def if_enabled(feature, context = nil, default_value = false, &blk)
        yield(blk) if is_enabled?(feature, context, default_value)
      end

      def get_variant(feature, context = Unleash::Context.new, fallback_variant = Unleash::FeatureToggle.disabled_variant)
        retrieve_toggles(context)

        toggle_as_hash = self.toggles.select{ |toggle| toggle['name'] == feature }&.first

        return Unleash::Variant.new(toggle_as_hash['variant']) if toggle_as_hash.is_a?(Hash) && toggle_as_hash.has_key?('variant')

        fallback_variant
      end

      private

      def retrieve_toggles(context)
        uri = URI(self.proxy_url)
        uri.query = context.as_uri_params unless context.nil?

        # Send the request, if possible
        begin
          toggles_response = Unleash::Util::Http.get(uri, nil, self.proxy_custom_http_headers)
        rescue StandardError => e
          Unleash.logger.error "unable to retrieve toggles from the unleash server due to exception #{e.class}:'#{e}'."
          Unleash.logger.error "stacktrace: #{e.backtrace}"
        end

        self.toggles = JSON.parse(toggles_response.body)['toggles'] || [] if toggles_response.is_a?(Net::HTTPSuccess)
        # TODO(rarruda): handle malformed responses
      end
    end
  end
end
