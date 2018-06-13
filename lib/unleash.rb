require 'unleash/version'
require 'unleash/configuration'
require 'unleash/client'
require 'logger'

module Unleash
    class << self
        attr_accessor :configuration, :toggle_fetcher, :toggles, :logger
    end

    def self.initialize
      self.toggles = []
    end

    # Support for configuration via yield:
    def self.configure(opts = {})
      self.configuration ||= Unleash::Configuration.new(opts)

      yield(configuration)

      configuration.validate!
      configuration.refresh_backup_file!
    end

end
