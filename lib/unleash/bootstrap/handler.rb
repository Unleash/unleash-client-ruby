require 'unleash/bootstrap/provider/from_url'
require 'unleash/bootstrap/provider/from_file'

module Unleash
  module Bootstrap
    class Handler
      attr_accessor :configuration

      def initialize(configuration)
        self.configuration = configuration
      end

      # @return [Hash] parsed JSON object from the configuration provided
      def retrieve_toggles
        bootstrap = get_bootstrap_data
        return JSON.parse(get_bootstrap_data) unless bootstrap.nil?
        {}
      end

      private

      def get_bootstrap_data
        return Provider::FromFile.read(configuration.file_path) unless self.configuration.file_path.nil?
        return Provider::FromUrl.read(configuration.url, configuration.url_headers) unless self.configuration.url.nil?
        return configuration.data unless self.configuration.data.nil?
        return configuration.klass.call if self.configuration.klass.is_a?(Proc)
      end
    end
  end
end
