require 'securerandom'
require 'tmpdir'

module Unleash
  class Configuration
    attr_accessor \
      :url,
      :app_name,
      :environment,
      :instance_id,
      :custom_http_headers,
      :disable_client,
      :disable_metrics,
      :timeout,
      :retry_limit,
      :refresh_interval,
      :metrics_interval,
      :backup_file,
      :logger,
      :log_level

    def initialize(opts = {})
      ensure_valid_opts(opts)
      set_defaults

      initialize_default_logger if opts[:logger].nil?

      merge(opts)
      refresh_backup_file!
    end

    def metrics_interval_in_millis
      self.metrics_interval * 1_000
    end

    def validate!
      return if self.disable_client

      raise ArgumentError, "URL and app_name are required parameters." if self.app_name.nil? || self.url.nil?
      raise ArgumentError, "custom_http_headers must be a hash." unless self.custom_http_headers.is_a?(Hash)
    end

    def refresh_backup_file!
      self.backup_file = Dir.tmpdir + "/unleash-#{app_name}-repo.json" if self.backup_file.nil?
    end

    def http_headers
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

    private

    def ensure_valid_opts(opts)
      unless opts[:custom_http_headers].is_a?(Hash) || opts[:custom_http_headers].nil?
        raise ArgumentError, "custom_http_headers must be a hash."
      end
    end

    def set_defaults
      self.app_name         = nil
      self.environment      = 'default'
      self.url              = nil
      self.instance_id      = SecureRandom.uuid
      self.disable_client   = false
      self.disable_metrics  = false
      self.refresh_interval = 15
      self.metrics_interval = 10
      self.timeout          = 30
      self.retry_limit      = 1
      self.backup_file      = nil
      self.log_level        = Logger::WARN

      self.custom_http_headers = {}
    end

    def initialize_default_logger
      self.logger = Logger.new(STDOUT)

      # on default logger, use custom formatter that includes thread_name:
      self.logger.formatter = proc do |severity, datetime, _progname, msg|
        thread_name = (Thread.current[:name] || "Unleash").rjust(16, ' ')
        "[#{datetime.iso8601(6)} #{thread_name} #{severity.ljust(5, ' ')}] : #{msg}\n"
      end
    end

    def merge(opts)
      opts.each_pair{ |opt, val| set_option(opt, val) }
      self
    end

    def set_option(opt, val)
      __send__("#{opt}=", val)
    rescue NoMethodError
      raise ArgumentError, "unknown configuration parameter '#{val}'"
    end
  end
end
