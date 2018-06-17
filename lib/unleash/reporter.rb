require 'unleash/configuration'
require 'net/http'
require 'json'
require 'time'

module Unleash

  class Metrics
    attr_accessor :features

    def initialize
      self.features = {}
    end

    def to_s
      self.features.to_json
    end

    def increment(feature, choice)
      raise "InvalidArgument choice must be :yes or :no" unless [:yes, :no].include? choice

      self.features[feature] = {yes: 0, no: 0} unless self.features.include? feature
      self.features[feature][choice] += 1
    end

    def reset
      self.features = {}
    end
  end

  class Reporter
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
          'start': start.iso8601,
          'stop': stop.iso8601,
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
      http.open_timeout = Unleash.configuration.timeout # in seconds
      http.read_timeout = Unleash.configuration.timeout # in seconds
      headers = {'Content-Type' => 'application/json'}
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = generated_report.to_json

      Unleash.logger.debug "Report to sent: #{request.body}"

      # Send the request
      response = http.request(request)

      if ['200','202'].include? response.code
        Unleash.logger.debug "Report sent to unleash server."
      else
        Unleash.logger.error "Error when sending report to unleash server. It responded with code #{response.code}."
      end

    end
  end
end