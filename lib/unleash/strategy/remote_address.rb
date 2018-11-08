module Unleash
  module Strategy
    class RemoteAddress < Base
      def name
        'remoteAddress'
      end

      # need: params['IPs'], context.remote_address
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('IPs')
        return false unless params.fetch('IPs', nil).is_a? String
        return false unless context.class.name == 'Unleash::Context'

        params['IPs'].split(',').map(&:strip).include?(context.remote_address)
      end
    end
  end
end
