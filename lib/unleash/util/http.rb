require 'net/http'
require 'uri'
require 'zlib'
require 'stringio'

module Unleash
  module Util
    module Http
      def self.get(uri, etag = nil, headers_override = nil)
        http = http_connection(uri)

        request = Net::HTTP::Get.new(uri.request_uri, http_headers(etag, headers_override))
        request.delete('Content-Encoding')

        http.request(request)
      end

      def self.post(uri, body)
        http = http_connection(uri)

        request = Net::HTTP::Post.new(uri.request_uri, http_headers)
        request_body =
          if request['Content-Encoding'] == 'gzip'
            request_body_writer = Zlib::GzipWriter.new(StringIO.new)
            request_body_writer << body
            request_body_writer.close.string
          else
            body
          end
        request.body = request_body

        http.request(request)
      end

      def self.http_connection(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.open_timeout = Unleash.configuration.timeout # in seconds
        http.read_timeout = Unleash.configuration.timeout # in seconds

        http
      end

      # @param etag [String, nil]
      # @param headers_override [Hash, nil]
      # @return [Hash]
      def self.http_headers(etag = nil, headers_override = nil)
        Unleash.logger.debug "ETag: #{etag}" unless etag.nil?

        headers = (Unleash.configuration.http_headers || {}).dup
        headers = headers_override if headers_override.is_a?(Hash)
        headers['Content-Type'] = 'application/json'
        headers['If-None-Match'] = etag unless etag.nil?

        headers
      end

      private_class_method :http_connection, :http_headers
    end
  end
end
