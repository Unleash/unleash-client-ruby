require "unleash/version"
require "unleash/configuration"
require "unleash/client"
# require "unleash/strategy/*"

require 'pp'

module Unleash

  # Hold configuration
  class << self
    attr_accessor :configuration
  end

  def self.configure(opts = {})
    self.configuration ||= Unleash::Configuration.new(opts)

    yield(configuration)

    configuration.validate!
    configuration.refresh_backup_file
  end


end
