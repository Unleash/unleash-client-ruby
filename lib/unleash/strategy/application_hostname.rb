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

      # def is_enabled?(params = {})
      #   is_enabled?(params, nil)
      # end

      # need: :params[:hostnames]
      def is_enabled?(params = {}, context = nil)
        return false if params.nil? || params.size == 0 || params['hostnames'].nil?

        params['hostnames'].split(",").map{|h| h.downcase }.include?(hostname)
      end
    end
  end
end
