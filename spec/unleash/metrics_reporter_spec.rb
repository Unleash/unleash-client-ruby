require "spec_helper"
require "rspec/json_expectations"

RSpec.describe Unleash::MetricsReporter do
  let(:metrics_reporter) { Unleash::MetricsReporter.new }

  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
    Unleash.logger.level = Unleash.configuration.log_level
    # Unleash.logger.level = Logger::DEBUG
    Unleash.toggles = []
    Unleash.toggle_metrics = {}

    Unleash.configuration.url         = 'http://test-url/'
    Unleash.configuration.app_name    = 'my-test-app'
    Unleash.configuration.instance_id = 'rspec/test'

    # Do not test the scheduled calls from client/metrics:
    Unleash.configuration.disable_client = true
    Unleash.configuration.disable_metrics = true
  end

  it "generates the correct report" do
    Unleash.configure do |config|
      config.url      = 'http://test-url/'
      config.app_name = 'my-test-app'
      config.instance_id = 'rspec/test'
      config.disable_client = true
    end
    Unleash.toggle_metrics = Unleash::Metrics.new

    Unleash.toggle_metrics.increment('featureA', :yes)
    Unleash.toggle_metrics.increment('featureA', :yes)
    Unleash.toggle_metrics.increment('featureA', :yes)
    Unleash.toggle_metrics.increment('featureA', :no)
    Unleash.toggle_metrics.increment('featureA', :no)
    Unleash.toggle_metrics.increment('featureB', :yes)

    report = metrics_reporter.generate_report
    expect(report[:bucket][:toggles]).to include(
      "featureA" => {
        no: 2,
        yes: 3
      },
      "featureB" => {
        no: 0,
        yes: 1
      }
    )

    expect(report[:bucket][:toggles].to_json).to include_json(
      featureA: {
        no: 2,
        yes: 3
      },
      featureB: {
        no: 0,
        yes: 1
      }
    )
  end

  it "sends the correct report" do
    WebMock.stub_request(:post, "http://test-url/client/metrics")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'Unleash-Appname' => 'my-test-app',
          'Unleash-Instanceid' => 'rspec/test',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    Unleash.toggle_metrics = Unleash::Metrics.new

    Unleash.toggle_metrics.increment('featureA', :yes)
    Unleash.toggle_metrics.increment('featureA', :yes)
    Unleash.toggle_metrics.increment('featureA', :yes)
    Unleash.toggle_metrics.increment('featureA', :no)
    Unleash.toggle_metrics.increment('featureA', :no)
    Unleash.toggle_metrics.increment('featureB', :yes)

    metrics_reporter.post

    expect(WebMock).to have_requested(:post, 'http://test-url/client/metrics')
      .with { |req|
        hash = JSON.parse(req.body)

        [
          DateTime.parse(hash['bucket']['stop']) >= DateTime.parse(hash['bucket']['start']),
          hash['bucket']['toggles']['featureA']['yes'] == 3,
          hash['bucket']['toggles']['featureA']['no'] == 2,
          hash['bucket']['toggles']['featureB']['yes'] == 1
        ].all?(true)
      }
      .with(
        body: hash_including(
          appName: "my-test-app",
          instanceId: "rspec/test"
        )
      )
  end

  it "does not send a report, if there were no metrics registered/evaluated" do
    Unleash.toggle_metrics = Unleash::Metrics.new

    metrics_reporter.post

    expect(WebMock).to_not have_requested(:post, 'http://test-url/client/metrics')
  end
end
