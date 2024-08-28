#!/usr/bin/env ruby

require 'unleash'
require 'unleash/context'

puts ">> START complex_properties_with_case_insensitive.rb"

@unleash = Unleash::Client.new(
  url: 'https://x.x.com/api',
  custom_http_headers: { 'Authorization': 'invalid' },
  app_name: 'simple-test',
  instance_id: 'local-test-cli',
  disable_client: true,
  disable_metrics: true,
  bootstrap_config: Unleash::Bootstrap::Configuration.new(file_path: "examples/complex-properties-case-insensitive.json")
)

context_params = {
  user_id: '123',
  session_id: 'verylongsesssionid',
  remote_address: '127.0.0.3',
  properties: {
    fancy: { foo: { "bar" => "baz" } }
  }
}

# feature_name = "AwesomeFeature"
feature_name = "4343443"
unleash_context = Unleash::Context.new(context_params)
#unleash_context.user_id = 123

sleep 1
if @unleash.is_enabled?(feature_name, unleash_context)
  puts "> #{feature_name} is enabled"
else
  puts "> #{feature_name} is not enabled"
end
sleep 1
puts "---"
puts ""
puts ""

puts "> shutting down client..."

@unleash.shutdown

puts ">> END complex_properties_with_case_insensitive.rb"
