require 'unleash/configuration'
require 'unleash/bootstrap/handler'
require 'net/http'
require 'json'
require 'yggdrasil_engine'

module Unleash
  class ToggleFetcher
    attr_accessor :toggle_engine, :toggle_lock, :toggle_resource, :etag, :retry_count, :segment_cache

    def initialize(engine)
      self.toggle_engine = engine
      self.etag = nil
      self.segment_cache = nil
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

    def toggles
      self.toggle_lock.synchronize do
        # wait for resource, only if it is null
        self.toggle_resource.wait(self.toggle_lock) if self.toggle_engine.nil?
        return self.toggle_engine
      end
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
      synchronize_with_local_cache!(response.body)

      update_running_client!
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

    def synchronize_with_local_cache!(toggle_data)
      self.toggle_lock.synchronize do
        self.toggle_engine.take_state(toggle_data)
      end

      # notify all threads waiting for this resource to no longer wait
      self.toggle_resource.broadcast
    end

    def update_running_client!
      if Unleash.engine != self.toggle_engine
        Unleash.engine = self.toggle_engine
      end
    end

    def read!
      Unleash.logger.debug "read!()"
      backup_file = Unleash.configuration.backup_file
      return nil unless File.exist?(backup_file)
      backup_data = File.read(backup_file)
      synchronize_with_local_cache!(backup_data)
      update_running_client!
    rescue IOError => e
      Unleash.logger.error "Unable to read the backup_file: #{e}"
    rescue JSON::ParserError => e
      Unleash.logger.error "Unable to parse JSON from existing backup_file: #{e}"
    rescue StandardError => e
      Unleash.logger.error "Unable to extract valid data from backup_file. Exception thrown: #{e}"
    end

    def bootstrap
      bootstrap_payload = Unleash::Bootstrap::Handler.new(Unleash.configuration.bootstrap_config).retrieve_toggles
      synchronize_with_local_cache! bootstrap_payload
      update_running_client!

      # reset Unleash.configuration.bootstrap_data to free up memory, as we will never use it again
      Unleash.configuration.bootstrap_config = nil
    end

    def build_segment_map(segments_array)
      return {} if segments_array.nil?

      segments_array.map{ |segment| [segment["id"], segment] }.to_h
    end
  end
end
