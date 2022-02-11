module Unleash
  module Bootstrap
    class Configuration
      attr_accessor :data, :file_path, :url, :url_headers, :block

      def initialize(opts = {})
        self.file_path = resolve_value_indifferently(opts, 'file_path') || ENV['UNLEASH_BOOTSTRAP_FILE'] || nil
        self.url = resolve_value_indifferently(opts, 'url') || ENV['UNLEASH_BOOTSTRAP_URL'] || nil
        self.url_headers = resolve_value_indifferently(opts, 'url_headers')
        self.data = resolve_value_indifferently(opts, 'data')
        self.block = resolve_value_indifferently(opts, 'block')
      end

      def valid?
        ![self.data, self.file_path, self.url, self.block].all?(&:nil?)
      end

      private

      def resolve_value_indifferently(opts, key)
        opts[key] || opts[key.to_sym]
      end
    end
  end
end
