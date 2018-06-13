#!/usr/bin/env ruby

require 'unleash'
require 'unleash/context'

puts ">> START simple.rb"

# Unleash.configure do |config|
#   config.url = 'http://unleash.herokuapp.com/api'
#   config.app_name = 'simple-test'
# end


# or:

@unleash = Unleash::Client.new( url: 'http://unleash.herokuapp.com/api', app_name: 'simple-test' )

# @unleash2 = Unleash::Client.new
#( url: 'http://unleash.herokuapp.com/api', app_name: 'simple-test2' )

# feature_name = "AwesomeFeature"
feature_name = "4343443"
unleash_context = Unleash::Context.new
unleash_context.user_id = 123

1.times do
  if @unleash.is_enabled?(feature_name, unleash_context)
    puts "> #{feature_name} is enabled"
  else
    puts "> #{feature_name} is not enabled"
  end
  puts ""
end


puts ">> END simple.rb"
