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
      metrics = Unleash&.engine&.get_metrics()

      {
        'platformName': RUBY_ENGINE,
        'platformVersion': RUBY_VERSION,
        'yggdrasilVersion': "0.13.3",
        'specVersion': Unleash::CLIENT_SPECIFICATION_VERSION,
        'appName': Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'bucket': metrics || {}
      }
    end

    def post
      Unleash.logger.debug "post() Report"

      report = self.generate_report

      if report[:bucket].empty? && (Time.now - self.last_time < LONGEST_WITHOUT_A_REPORT) # and last time is less then 10 minutes...
        Unleash.logger.debug "Report not posted to server, as it would have been empty. (and has been empty for up to 10 min)"
        return
      end

      response = Unleash::Util::Http.post(Unleash.configuration.client_metrics_uri, report.to_json)

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
