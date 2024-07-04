require 'rubygems'
gemspec = Gem::Specification.load('unleash-client.gemspec')
puts gemspec.metadata['client-specification-version']
