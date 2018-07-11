require "bundler/setup"
require "unleash"
require "unleash/client"

require 'webmock/rspec'

require 'coveralls'
Coveralls.wear!

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
