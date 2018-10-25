require 'unleash/configuration'
require 'unleash/metrics'
require 'net/http'
require 'json'
require 'time'

module Unleash

  class MetricsReporter
    attr_accessor :last_time, :client

    def initialize
      self.last_time = Time.now
    end

    def build_hash
    end

    def generate_report
      now = Time.now
      start, stop, self.last_time = self.last_time, now, now
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
      return report
    end

    def send
      Unleash.logger.debug "send() Report"

      generated_report = self.generate_report()

      uri = URI(Unleash.configuration.client_metrics_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = Unleash.configuration.timeout # in seconds
      http.read_timeout = Unleash.configuration.timeout # in seconds

      headers = (Unleash.configuration.get_http_headers || {}).dup
      headers['Content-Type'] = 'application/json'
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = generated_report.to_json

      Unleash.logger.debug "Report to send: #{request.body}"

      response = http.request(request)

      if ['200','202'].include? response.code
        Unleash.logger.debug "Report sent to unleash server sucessfully. Server responded with http code #{response.code}"
      else
        Unleash.logger.error "Error when sending report to unleash server. Server responded with http code #{response.code}."
      end

    end
  end
end
