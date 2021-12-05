#!/usr/bin/env ruby

require 'unleash'
require 'unleash/context'

puts ">> START simple.rb"

# Unleash.configure do |config|
#   config.url = 'http://unleash.herokuapp.com/api'
#   config.custom_http_headers = { 'Authorization': '943ca9171e2c884c545c5d82417a655fb77cec970cc3b78a8ff87f4406b495d0' }
#   config.app_name = 'simple-test'
#   config.refresh_interval = 2
#   config.metrics_interval = 2
#   config.retry_limit = 2
# end
# @unleash = Unleash::Client.new

# or:

@unleash = Unleash::Client.new(
  url: 'http://unleash.herokuapp.com/api',
  custom_http_headers: { 'Authorization': '943ca9171e2c884c545c5d82417a655fb77cec970cc3b78a8ff87f4406b495d0' },
  app_name: 'simple-test',
  instance_id: 'local-test-cli',
  refresh_interval: 2,
  metrics_interval: 2,
  retry_limit: 2
)

# feature_name = "AwesomeFeature"
feature_name = "4343443"
unleash_context = Unleash::Context.new
unleash_context.user_id = 123

sleep 1
3.times do
  if @unleash.is_enabled?(feature_name, unleash_context)
    puts "> #{feature_name} is enabled"
  else
    puts "> #{feature_name} is not enabled"
  end
  sleep 1
  puts "---"
  puts ""
  puts ""
end

sleep 3
feature_name = "foobar"
if @unleash.is_enabled?(feature_name, unleash_context, true)
  puts "> #{feature_name} is enabled"
else
  puts "> #{feature_name} is not enabled"
end

puts "> shutting down client..."

@unleash.shutdown

puts ">> END simple.rb"
