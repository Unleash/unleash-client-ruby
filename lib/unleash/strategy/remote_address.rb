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

        remote_address = IPAddr.new(context.remote_address) rescue nil

        params[PARAM]
          .split(',')
          .map(&:strip)
          .map{ |ipblock| IPAddr.new(ipblock) rescue nil }
          .compact
          .map{ |ipb| ipb.include? remote_address }
          .any?
      end
    end
  end
end
