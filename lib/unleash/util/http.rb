require 'net/http'
require 'uri'

module Unleash
  module Util
    module Http
      def self.get(uri, etag = nil)
        http = http_connection(uri)

        request = Net::HTTP::Get.new(uri.request_uri, http_headers(etag))

        http.request(request)
      end

      def self.post(uri, body)
        http = http_connection(uri)

        request = Net::HTTP::Post.new(uri.request_uri, http_headers)
        request.body = body

        http.request(request)
      end

      def self.http_connection(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.open_timeout = Unleash.configuration.timeout # in seconds
        http.read_timeout = Unleash.configuration.timeout # in seconds

        http
      end

      def self.http_headers(etag = nil)
        Unleash.logger.debug "ETag: #{etag}" unless etag.nil?

        headers = (Unleash.configuration.http_headers || {}).dup
        headers['Content-Type'] = 'application/json'
        headers['If-None-Match'] = etag unless etag.nil?

        headers
      end

      private_class_method :http_connection, :http_headers
    end
  end
end
