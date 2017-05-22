#!/usr/bin/env ruby

require 'unleash'

puts "foo start"

Unleash.configure do |config|
  config.url = 'http://unleash.herokuapp.com/api'
  config.app_name = 'simple-test'
end


# or:

# UNLEASH = Unleash.new( url: 'http://unleash.herokuapp.com/api' )
@unleash = Unleash::Client.new
#( url: 'http://unleash.herokuapp.com/api', app_name: 'simple-test2' )

if @unleash.is_enabled?("AwesomeFeature")
  puts "AwesomeFeature is enabled"
else
  puts "AwesomeFeature is not enabled"
end

