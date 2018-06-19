require 'securerandom'
require 'tmpdir'

module Unleash
  class Configuration
    attr_accessor :url, :app_name, :instance_id,
      :disable_metrics, :timeout, :retry_limit,
      :refresh_interval, :metrics_interval,
      :backup_file, :log_level

    def initialize(opts = {})
      self.app_name      = opts[:app_name]    || nil
      self.url           = opts[:url]         || nil
      self.instance_id   = opts[:instance_id] || SecureRandom.uuid

      self.disable_metrics  = opts[:disable_metrics]  || false
      self.refresh_interval = opts[:refresh_interval] || 15
      self.metrics_interval = opts[:metrics_interval] || 10
      self.timeout          = opts[:timeout] || 30
      self.retry_limit      = opts[:retry_limit] || 1

      self.backup_file   = opts[:backup_file] || nil

      self.log_level = opts[:log_level] || 'FATAL'

      refresh_backup_file!
    end

    def metrics_interval_in_millis
      self.metrics_interval * 1_000
    end

    def validate!
      if self.app_name.nil? or self.url.nil?
        raise ArgumentError, "URL and app_name are required"
      end
    end

    def refresh_backup_file!
      if self.backup_file.nil?
        self.backup_file = Dir.tmpdir + "/unleash-#{app_name}-repo.json"
      end
    end

    def fetch_toggles_url
      self.url + '/features'
    end

    def client_metrics_url
      self.url + '/client/metrics'
    end

    def client_register_url
      self.url + '/client/register'
    end

  end
end