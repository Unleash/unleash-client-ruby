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
      puts "Making report"
      metrics = Unleash&.engine&.get_metrics()
      if metrics.nil? || metrics.empty?
        puts "nothing here"
        return nil
      end
      report = {
        'appName': Unleash.configuration.app_name,
        'instanceId': Unleash.configuration.instance_id,
        'bucket': metrics
      }

      report
    end

    def post
      Unleash.logger.debug "post() Report"

      bucket = self.generate_report
      if bucket.nil? && (Time.now - self.last_time < LONGEST_WITHOUT_A_REPORT) # and last time is less then 10 minutes...
        Unleash.logger.debug "Report not posted to server, as it would have been empty. (and has been empty for up to 10 min)"

        return
      end

      response = Unleash::Util::Http.post(Unleash.configuration.client_metrics_uri, bucket.to_json)

      if ['200', '202'].include? response.code
        Unleash.logger.debug "Report sent to unleash server successfully. Server responded with http code #{response.code}"
      else
        Unleash.logger.error "Error when sending report to unleash server. Server responded with http code #{response.code}."
      end
    end

    private
  end
end
