module Unleash
  module Bootstrap
    class FromFile < Base
      attr_accessor :file_path

      # @param file_path [String]
      def initialize(file_path)
        self.file_path = file_path
      end

      def read
        file_content = File.read(self.file_path)
        bootstrap_hash = JSON.parse(file_content)
        extract_features(bootstrap_hash)
      end
    end
  end
end
