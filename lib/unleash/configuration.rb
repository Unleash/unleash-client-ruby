require 'securerandom'
require 'tmpdir'

module Unleash
  class Configuration
    attr_accessor :url, :app_name, :instance_id,
      :custom_http_headers,
      :disable_client,
      :disable_metrics, :timeout, :retry_limit,
      :refresh_interval, :metrics_interval,
      :backup_file, :logger, :log_level

    def initialize(opts = {})
      self.app_name      = opts[:app_name]    || nil
      self.url           = opts[:url]         || nil
      self.instance_id   = opts[:instance_id] || SecureRandom.uuid

      if opts[:custom_http_headers].is_a?(Hash) || opts[:custom_http_headers].nil?
        self.custom_http_headers = opts[:custom_http_headers] || {}
      else
        raise ArgumentError, "custom_http_headers must be a hash."
      end
      self.disable_client   = opts[:disable_client]   || false
      self.disable_metrics  = opts[:disable_metrics]  || false
      self.refresh_interval = opts[:refresh_interval] || 15
      self.metrics_interval = opts[:metrics_interval] || 10
      self.timeout          = opts[:timeout] || 30
      self.retry_limit      = opts[:retry_limit] || 1

      self.backup_file   = opts[:backup_file] || nil

      self.logger    = opts[:logger] || Logger.new(STDOUT)
      self.log_level = opts[:log_level] || Logger::WARN


      if opts[:logger].nil?
        # on default logger, use custom formatter that includes thread_name:
        self.logger.formatter = proc do |severity, datetime, progname, msg|
          thread_name = (Thread.current[:name] || "Unleash").rjust(16, ' ')
          "[#{datetime.iso8601(6)} #{thread_name} #{severity.ljust(5, ' ')}] : #{msg}\n"
        end
      end

      refresh_backup_file!
    end

    def metrics_interval_in_millis
      self.metrics_interval * 1_000
    end

    def validate!
      return if self.disable_client

      raise ArgumentError, "URL and app_name are required parameters." if self.app_name.nil? or self.url.nil?
      raise ArgumentError, "custom_http_headers must be a hash." unless self.custom_http_headers.is_a?(Hash)
    end

    def refresh_backup_file!
      if self.backup_file.nil?
        self.backup_file = Dir.tmpdir + "/unleash-#{app_name}-repo.json"
      end
    end

    def get_http_headers
      {
        'UNLEASH-INSTANCEID' => self.instance_id,
        'UNLEASH-APPNAME' => self.app_name
      }.merge(custom_http_headers.dup)
    end

    def fetch_toggles_url
      self.url + '/client/features'
    end

    def client_metrics_url
      self.url + '/client/metrics'
    end

    def client_register_url
      self.url + '/client/register'
    end

  end
end
