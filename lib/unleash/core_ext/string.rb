module Unleash
  module CoreExtensions
    module String
      def delete_suffix(suffix)
        return self[0..(self.length - 1 - suffix.length)] if self.end_with?(suffix)
        self
      end
    end
  end
end
