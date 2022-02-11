module Unleash
  module Bootstrap
    class Configuration
      attr_accessor :data, :file_path, :url, :url_headers, :closure

      def initialize(opts = {})
        self.file_path = self.resolve_value_indifferently(opts, 'file_path') || ENV['UNLEASH_BOOTSTRAP_FILE'] || nil
        self.url = self.resolve_value_indifferently(opts, 'url') || ENV['UNLEASH_BOOTSTRAP_URL'] || nil
        self.url_headers = self.resolve_value_indifferently(opts, 'url_headers')
        self.data = self.resolve_value_indifferently(opts, 'data')
        self.closure = self.resolve_value_indifferently(opts, 'closure')
      end

      def valid?
        !(self.data || self.file_path || self.url || self.closure).nil?
      end

      private

      def resolve_value_indifferently(opts, key)
        opts[key] || opts[key.to_sym]
      end
    end
  end
end
