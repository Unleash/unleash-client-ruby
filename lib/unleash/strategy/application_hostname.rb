require 'socket'

module Unleash
  module Strategy
    class ApplicationHostname < Base
      attr_accessor :hostname
      PARAM = 'hostnames'.freeze

      def initialize
        self.hostname = Socket.gethostname || 'undefined'
      end

      def name
        'applicationHostname'
      end

      # need: :params['hostnames']
      def is_enabled?(params = {}, _context = nil)
        return false unless params.is_a?(Hash) && params.has_key?(PARAM)

        params[PARAM].split(",").map(&:strip).map(&:downcase).include?(self.hostname)
      end
    end
  end
end
