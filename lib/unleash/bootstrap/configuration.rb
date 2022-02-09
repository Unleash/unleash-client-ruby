module Unleash
  module Bootstrap
    class Configuration
      attr_accessor :data, :file_path, :url, :url_headers, :klass

      def initialize(opts = {})
        self.file_path = opts['file_path'] || ENV['UNLEASH_BOOTSTRAP_FILE'] || nil
        self.url = opts['url'] || ENV['UNLEASH_BOOTSTRAP_URL'] || nil
        self.url_headers = opts['url_headers']
        self.data = opts['data']
        self.klass = opts['klass']
      end

      def valid?
        !(@data.nil? && @file_path.nil? && @url.nil? && @klass.nil?)
      end
    end
  end
end
