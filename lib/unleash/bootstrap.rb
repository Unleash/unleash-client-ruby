require 'unleash/configuration'
require 'unleash/feature_toggle'
require 'logger'
require 'time'
require 'net/http'
require 'uri'

module Unleash
  class FileBootStrapper
    attr_accessor :file_path

    def initialize(file_path)
      self.file_path = file_path
    end

    def read
      file_content = File.read(self.file_path)
      bootstrap_hash = JSON.parse(file_content)
      Unleash.extract_bootstrap(bootstrap_hash)
    end
  end

  class UrlBootStrapper
    attr_accessor :uri, :headers

    def initialize(uri, headers)
      self.uri = URI(uri)
      self.headers = headers
    end

    def read
      request = Net::HTTP::Get.new(self.uri, self.build_headers(self.headers))

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = Unleash.configuration.timeout
      http.read_timeout = Unleash.configuration.timeout

      http.request(request)
    end

    def build_headers(headers = nil)
      headers = (headers || {}).dup
      headers['Content-Type'] = 'application/json'

      headers
    end
  end

  def self.extract_bootstrap(bootstrap_hash)
    raise NotImplemented, "The provided bootstrap doesn't seem to be a valid set of toggles" if bootstrap_hash['version'] < 1

    bootstrap_hash['features']
  end
end
