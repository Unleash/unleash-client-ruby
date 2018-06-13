require 'socket'

module Unleash
  module Strategy
    class ApplicationHostname < Base
      # HOST_NAMES_PARAM = "hostNames"

      private
      attr_accessor :hostname

      public
      def initialize
        hostname = Socket.gethostname || 'undefined'
      end

      def name
        'applicationHostname'
      end

      # need: :params[:hostnames]
      def is_enabled?(params = {})
        return false if params.nil? || params.size == 0

        params['hostnames'].split(",").map{|h| h.downcase }.include?(hostname)
      end
    end
  end
end
