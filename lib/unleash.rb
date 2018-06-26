require 'unleash/version'
require 'unleash/configuration'
require 'unleash/context'
require 'unleash/client'
require 'logger'

module Unleash
  TIME_RESOLUTION = 3

  class << self
    attr_accessor :configuration, :toggle_fetcher, :toggles, :toggle_metrics, :reporter, :logger
  end

  def self.initialize
    self.toggles = []
    self.toggle_metrics = {}
  end

  # Support for configuration via yield:
  def self.configure()
    self.configuration ||= Unleash::Configuration.new
    yield(configuration)

    self.configuration.validate!
    self.configuration.refresh_backup_file!
  end

end
