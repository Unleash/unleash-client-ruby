require 'unleash/version'
require 'unleash/configuration'
require 'unleash/strategy/base'
require 'unleash/context'
require 'unleash/client'
require 'logger'

Gem.find_files('unleash/strategy/**/*.rb').each{ |path| require path }

module Unleash
  TIME_RESOLUTION = 3

  STRATEGIES = Unleash::Strategy.constants
    .select{ |c| Unleash::Strategy.const_get(c).is_a? Class }
    .reject{ |c| ['NotImplemented', 'Base'].include?(c.to_s) }
    .map do |c|
      lowered_c = c.to_s
      lowered_c[0] = lowered_c[0].downcase
      [lowered_c.to_sym, Object.const_get("Unleash::Strategy::#{c}").new]
    end
    .to_h

  class << self
    attr_accessor :configuration, :toggle_fetcher, :toggles, :toggle_metrics, :reporter, :logger
  end

  def self.initialize
    self.toggles = []
    self.toggle_metrics = {}
  end

  # Support for configuration via yield:
  def self.configure
    self.configuration ||= Unleash::Configuration.new
    yield(configuration)

    self.configuration.validate!
    self.configuration.refresh_backup_file!
  end
end
