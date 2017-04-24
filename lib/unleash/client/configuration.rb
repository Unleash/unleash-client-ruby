require 'securerandom'

module Unleash
  module Client
    class Configuration
      attr_accessor :url, :app_name, :instance_id, :timeout, :retry_limit

      def initialize(opts = {})
        self.url = opts[:url] || 'http://unleash.herokuapp.com/api'
        self.app_name = opts[:app_name]
        self.instance_id = opts[:instance_id] || SecureRandom.uuid

        self.refresh_interval = opts[:refresh_interval] || 15
        self.metrics_interval = opts[:metrics_interval] || nil
        self.timeout = opts[:timeout] || 30
        self.retry_limit = opts[:retry_limit] || 1
      end
    end
  end
end