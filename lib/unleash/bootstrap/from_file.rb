module Unleash
  module Bootstrap
    class FromFile < Base
      # @param file_path [String]
      def self.read(file_path)
        File.read(file_path)
      end
    end
  end
end
