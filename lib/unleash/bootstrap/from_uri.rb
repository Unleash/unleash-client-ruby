module Unleash
  module Bootstrap
    class FromUri < Base
      attr_accessor :uri, :headers

      # @param uri [String]
      # @param headers [Hash, nil] HTTP headers to use. If not set, the unleash client SDK ones will be used.
      def initialize(uri, headers = nil)
        self.uri = URI(uri)
        self.headers = headers
      end

      def read
        response = Unleash::Util::Http.get(self.uri, nil, self.headers)
        bootstrap_hash = JSON.parse(response.body)
        extract_features(bootstrap_hash)
      end
    end
  end
end
