module Unleash
  module Strategy
    class RemoteAddress < Base
      PARAM = 'IPs'.freeze

      def name
        'remoteAddress'
      end

      # need: params['IPs'], context.remote_address
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?(PARAM)
        return false unless params.fetch(PARAM, nil).is_a? String
        return false unless context.class.name == 'Unleash::Context'

        params[PARAM].split(',').map(&:strip).include?(context.remote_address)
      end
    end
  end
end
