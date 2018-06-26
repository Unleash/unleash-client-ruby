require 'socket'

module Unleash
  module Strategy
    class ApplicationHostname < Base
      attr_accessor :hostname

      def initialize
        self.hostname = Socket.gethostname || 'undefined'
      end

      def name
        'applicationHostname'
      end

      # need: :params[:hostnames]
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('hostnames')

        params['hostnames'].split(",").map(&:strip).map{|h| h.downcase }.include?(self.hostname)
      end
    end
  end
end
