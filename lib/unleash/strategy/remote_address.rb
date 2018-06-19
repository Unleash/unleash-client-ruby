module Unleash
  module Strategy
    class RemoteAddress < Base
      def name
        'remoteAddress'
      end

      # need: params['ips'], context.remote_address
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('ips')
        return false unless params.fetch('ips', nil).is_a? String
        return false unless context.class.name == 'Unleash::Context'

        params['ips'].split(',').map(&:strip).include?( context.remote_address )
      end
    end
  end
end
