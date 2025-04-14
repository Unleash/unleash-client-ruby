require 'unleash/configuration'
require 'net/http'
require 'json'
require 'time'

module Unleash
  class MetricsReporter
    LONGEST_WITHOUT_A_REPORT = 600

    attr_accessor :last_time

    def initialize
      self.last_time = Time.now
    end

    def generate_report
      metrics = Unleash.engine&.get_metrics
      return nil if metrics.nil?

      generate_report_from_bucket metrics
    end

    def generate_report_from_bucket(bucket)
      {
        'platformName': RUBY_ENGINE,
        'platformVersion': RUBY_VERSION,
        'yggdrasilVersion': "0.13.3",
        'specVersion': Unleash::CLIENT_SPECIFICATION_VERSION,
        'appName': Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'connectionId': Unleash.configuration.connection_id,
        'bucket': bucket
      }
    end

    def post
      Unleash.logger.debug "post() Report"

      report = self.generate_report

      if report.nil?
        return if Time.now - self.last_time < LONGEST_WITHOUT_A_REPORT

        Unleash.logger.debug "Sending empty report to server as 10 minutes have passed since last report"
        report = self.generate_report_from_bucket({
          'start': self.last_time.utc.iso8601,
          'stop': Time.now.utc.iso8601,
          'toggles': {}
        })
      end

      self.last_time = Time.now

      headers = (Unleash.configuration.http_headers || {}).dup
      headers.merge!({ 'UNLEASH-INTERVAL' => Unleash.configuration.metrics_interval.to_s })
      response = Unleash::Util::Http.post(Unleash.configuration.client_metrics_uri, report.to_json, headers)

      if ['200', '202'].include? response.code
        Unleash.logger.debug "Report sent to unleash server successfully. Server responded with http code #{response.code}"
      else
        # :nocov:
        Unleash.logger.error "Error when sending report to unleash server. Server responded with http code #{response.code}."
        # :nocov:
      end
    end
  end
end
