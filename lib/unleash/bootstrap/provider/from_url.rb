require 'unleash/bootstrap/provider/base'

module Unleash
  module Bootstrap
    module Provider
      class FromUrl < Base
        # @param url [String]
        # @param headers [Hash, nil] HTTP headers to use. If not set, the unleash client SDK ones will be used.
        def self.read(url, headers = nil)
          response = Unleash::Util::Http.get(URI.parse(url), nil, headers)

          return nil if response.code != '200'

          response.body
        end
      end
    end
  end
end
