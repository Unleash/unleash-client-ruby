require 'unleash/version'
require 'unleash/spec_version'
require 'unleash/configuration'
require 'unleash/strategies'
require 'unleash/context'
require 'unleash/client'
require 'logger'

module Unleash
  TIME_RESOLUTION = 3

  class << self
    attr_accessor :configuration, :toggle_fetcher, :reporter, :logger, :engine
  end

  self.configuration = Unleash::Configuration.new

  # Deprecated: Use Unleash.configure to add custom strategies
  STRATEGIES = self.configuration.strategies

  # Support for configuration via yield:
  def self.configure
    yield(configuration)

    self.configuration.validate!
    self.configuration.refresh_backup_file!
  end

  def self.strategies
    self.configuration.strategies
  end
end
