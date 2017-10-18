module Unleash
  module Strategy
    class RemoteAddress < Base
      def name
        'remoteAddress'
      end

      # need: params[:ips], context.remote_address
      def is_enabled?(params = {}, context = nil)
        return false if params.nil? || params.size == 0
        return false if context.class.name != 'Unleash::Context'

        ips = (params[:ips] || "").split(',')
        ips.include?( context.remote_address )
      end
    end
  end
end
