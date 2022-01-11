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

        remote_address = ipaddr_or_nil_from_str(context.remote_address)

        params[PARAM]
          .split(',')
          .map(&:strip)
          .map{ |ipblock| ipaddr_or_nil_from_str(ipblock) }
          .compact
          .map{ |ipb| ipb.include? remote_address }
          .any?
      end

      private

      def ipaddr_or_nil_from_str(ip)
        IPAddr.new(ip)
      rescue StandardError
        nil
      end
    end
  end
end
