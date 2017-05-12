#!/usr/bin/env ruby

require 'unleash'

Unleash.configure do |config|
  config.server = 'http://unleash.herokuapp.com/api'
end

# or:

UNLEASH = Unleash.new( server: 'http://unleash.herokuapp.com/api' )

puts "foo" if @unleash.is_enabled("AwesomeFeature")

