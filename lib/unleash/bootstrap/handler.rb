module Unleash
  module Bootstrap
    class Handler
      attr_accessor :configuration

      # @return [Hash] parsed JSON object from the configuration provided
      def retrieve_toggles
        return JSON.parse(FromFile.read(configuration.file_path)) unless self.configuration.file_path.nil?
        return JSON.parse(FromUrl.read(configuration.url, configuration.http_headers)) unless self.configuration.url.nil?
        return configuration.data unless self.configuration.data.nil?
        return configuration.klass.call unless self.configuration.klass.is_a?(Proc)

        List.new
      end
    end
  end
end
