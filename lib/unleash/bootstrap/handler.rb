require 'unleash/bootstrap/provider/from_url'
require 'unleash/bootstrap/provider/from_file'

module Unleash
  module Bootstrap
    class Handler
      attr_accessor :configuration

      def initialize(configuration)
        self.configuration = configuration
      end

      # @return [String] JSON string representing data returned from an Unleash server
      def retrieve_toggles
        return configuration.data unless self.configuration.data.nil?
        return configuration.block.call if self.configuration.block.is_a?(Proc)
        return Provider::FromFile.read(configuration.file_path) unless self.configuration.file_path.nil?
        return Provider::FromUrl.read(configuration.url, configuration.url_headers) unless self.configuration.url.nil?
      end
    end
  end
end
