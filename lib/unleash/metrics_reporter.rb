require 'unleash/configuration'
require 'unleash/metrics'
require 'net/http'
require 'json'
require 'time'

module Unleash
  class MetricsReporter
    attr_accessor :last_time

    def initialize
      self.last_time = Time.now
    end

    def generate_report
      now = Time.now

      start = self.last_time
      stop  = now
      self.last_time = now

      report = {
        'appName': Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'bucket': {
          'start': start.iso8601(Unleash::TIME_RESOLUTION),
          'stop': stop.iso8601(Unleash::TIME_RESOLUTION),
          'toggles': Unleash.toggle_metrics.features
        }
      }
      Unleash.toggle_metrics.reset

      report
    end

    def send
      Unleash.logger.debug "send() Report"

      response = Unleash::Util::Http.post(Unleash.configuration.client_metrics_url, self.generate_report.to_json)

      if ['200', '202'].include? response.code
        Unleash.logger.debug "Report sent to unleash server sucessfully. Server responded with http code #{response.code}"
      else
        Unleash.logger.error "Error when sending report to unleash server. Server responded with http code #{response.code}."
      end
    end
  end
end
