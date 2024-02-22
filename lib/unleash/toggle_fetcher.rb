require 'unleash/configuration'
require 'unleash/bootstrap/handler'
require 'net/http'
require 'json'
require 'yggdrasil_engine'

module Unleash
  class ToggleFetcher
    attr_accessor :toggle_engine, :toggle_lock, :toggle_resource, :etag, :retry_count

    def initialize(engine)
      self.toggle_engine = engine
      self.etag = nil
      self.toggle_lock = Mutex.new
      self.toggle_resource = ConditionVariable.new
      self.retry_count = 0

      begin
        # if bootstrap configuration is available, initialize. An immediate API read is also triggered
        if Unleash.configuration.use_bootstrap?
          bootstrap
        else
          fetch
        end
      rescue StandardError => e
        # fail back to reading the backup file
        Unleash.logger.warn "ToggleFetcher was unable to fetch from the network, attempting to read from backup file."
        Unleash.logger.debug "Exception Caught: #{e}"
        read!
      end

      # once initialized, somewhere else you will want to start a loop with fetch()
    end

    # rename to refresh_from_server!  ??
    def fetch
      Unleash.logger.debug "fetch()"
      return if Unleash.configuration.disable_client

      response = Unleash::Util::Http.get(Unleash.configuration.fetch_toggles_uri, etag)

      if response.code == '304'
        Unleash.logger.debug "No changes according to the unleash server, nothing to do."
        return
      elsif response.code != '200'
        raise IOError, "Unleash server returned a non 200/304 HTTP result."
      end

      self.etag = response['ETag']

      # always synchronize with the local cache when fetching:
      update_engine_state!(response.body)

      save! response.body
    end

    def save!(toggle_data)
      Unleash.logger.debug "Will save toggles to disk now"

      backup_file = Unleash.configuration.backup_file
      backup_file_tmp = "#{backup_file}.tmp"

      self.toggle_lock.synchronize do
        File.open(backup_file_tmp, "w") do |file|
          file.write(toggle_data)
        end
        File.rename(backup_file_tmp, backup_file)
      end
    rescue StandardError => e
      # This is not really the end of the world. Swallowing the exception.
      Unleash.logger.error "Unable to save backup file. Exception thrown #{e.class}:'#{e}'"
      Unleash.logger.error "stacktrace: #{e.backtrace}"
    end

    private

    def update_engine_state!(toggle_data)
      self.toggle_lock.synchronize do
        self.toggle_engine.take_state(toggle_data)
      end

      # notify all threads waiting for this resource to no longer wait
      self.toggle_resource.broadcast
    end

    def read!
      Unleash.logger.debug "read!()"
      backup_file = Unleash.configuration.backup_file
      return nil unless File.exist?(backup_file)

      backup_data = File.read(backup_file)
      update_engine_state!(backup_data)
    rescue IOError => e
      # :nocov:
      Unleash.logger.error "Unable to read the backup_file: #{e}"
      # :nocov:
    rescue JSON::ParserError => e
      # :nocov:
      Unleash.logger.error "Unable to parse JSON from existing backup_file: #{e}"
      # :nocov:
    rescue StandardError => e
      # :nocov:
      Unleash.logger.error "Unable to extract valid data from backup_file. Exception thrown: #{e}"
      # :nocov:
    end

    def bootstrap
      bootstrap_payload = Unleash::Bootstrap::Handler.new(Unleash.configuration.bootstrap_config).retrieve_toggles
      update_engine_state! bootstrap_payload

      # reset Unleash.configuration.bootstrap_data to free up memory, as we will never use it again
      Unleash.configuration.bootstrap_config = nil
    end
  end
end
