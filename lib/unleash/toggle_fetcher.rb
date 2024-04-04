require 'unleash/configuration'
require 'unleash/bootstrap/handler'
require 'unleash/util/executor_result'
require 'net/http'
require 'json'

module Unleash
  class ToggleFetcher
    attr_accessor :toggle_cache, :toggle_lock, :toggle_resource, :etag, :retry_count, :segment_cache

    def initialize
      self.etag = nil
      self.toggle_cache = nil
      self.segment_cache = nil
      self.toggle_lock = Mutex.new
      self.toggle_resource = ConditionVariable.new
      self.retry_count = 0

      begin
        # if bootstrap configuration is available, initialize. An immediate API read is also triggered
        if Unleash.configuration.use_bootstrap?
          bootstrap
        else
          ret = fetch
          # https://docs.ruby-lang.org/en/3.2/Exception.html#class-Exception-label-Custom+Exceptions
          raise StandardError "Unable to fetch toggles from the server" unless ret == Unleash::Util::ExecutorResult::SUCCESS
        end
      rescue StandardError => e
        # fail back to reading the backup file
        Unleash.logger.warn "ToggleFetcher was unable to fetch from the network, attempting to read from backup file."
        Unleash.logger.debug "Exception Caught: #{e}"
        read!
      end

      # once initialized, somewhere else you will want to start a loop with fetch()
    end

    # @return [Hash]
    def toggles
      self.toggle_lock.synchronize do
        # wait for resource, only if it is null
        self.toggle_resource.wait(self.toggle_lock) if self.toggle_cache.nil?
        return self.toggle_cache
      end
    end

    # rename to refresh_from_server!  ??
    # @return [integer]
    def fetch
      Unleash.logger.debug "fetch()"
      return Unleash::Util::ExecutorResult::SUCCESS if Unleash.configuration.disable_client

      response = Unleash::Util::Http.get(Unleash.configuration.fetch_toggles_uri, etag)

      # to be extracted:
      case response.code
      when '200' # Net::HTTPOK
        Unleash.logger.debug "Received 200 OK from unleash server, will update local cache."
      when '304' # Net::HTTPNotModified
        Unleash.logger.debug "No changes according to the unleash server, nothing to do."
        return Unleash::Util::ExecutorResult::SUCCESS
      when '429' # Net::HTTPTooManyRequests
        Unleash.logger.warn "Unleash server requested via HTTP result that we retry later. HTTP code: #{response.code}"
        return Unleash::Util::ExecutorResult::TEMPORARY_FAILURE
      when '500'..'599' # Net::HTTPServerError
        Unleash.logger.warn "Unleash server returned a server error. Consider it a permanent failure. HTTP code: #{response.code}"
        return Unleash::Util::ExecutorResult::TEMPORARY_FAILURE
      when '401', '403', '404' # Net::HTTPUnauthorized, Net::HTTPForbidden, Net::HTTPNotFound
        Unleash.logger.error "Unleash server returned invalid code. Consider it a permanent failure. HTTP code: #{response.code}"
        return Unleash::Util::ExecutorResult::PERMANENT_FAILURE
      else
        Unleash.logger.error "Unleash server returned unexpected result. Consider it a permanent failure. HTTP code: #{response.code}"
        return Unleash::Util::ExecutorResult::PERMANENT_FAILURE
      end

      self.etag = response['ETag']
      features = get_features(response.body)

      # always synchronize with the local cache when fetching:
      synchronize_with_local_cache!(features)

      update_running_client!
      save!

      Unleash::Util::ExecutorResult::SUCCESS
    end

    def save!
      Unleash.logger.debug "Will save toggles to disk now"

      backup_file = Unleash.configuration.backup_file
      backup_file_tmp = "#{backup_file}.tmp"

      self.toggle_lock.synchronize do
        File.open(backup_file_tmp, "w") do |file|
          file.write(self.toggle_cache.to_json)
        end
        File.rename(backup_file_tmp, backup_file)
      end
    rescue StandardError => e
      # This is not really the end of the world. Swallowing the exception.
      Unleash.logger.error "Unable to save backup file. Exception thrown #{e.class}:'#{e}'"
      Unleash.logger.error "stacktrace: #{e.backtrace}"
    end

    private

    def synchronize_with_local_cache!(features)
      if self.toggle_cache != features
        self.toggle_lock.synchronize do
          self.toggle_cache = features
        end

        # notify all threads waiting for this resource to no longer wait
        self.toggle_resource.broadcast
      end
    end

    def update_running_client!
      if Unleash.toggles != self.toggles["features"] || Unleash.segment_cache != self.toggles["segments"]
        Unleash.logger.info "Updating toggles to main client, there has been a change in the server."
        Unleash.toggles = self.toggles["features"]
        Unleash.segment_cache = self.toggles["segments"]
      end
    end

    def read!
      Unleash.logger.debug "read!()"
      backup_file = Unleash.configuration.backup_file
      return nil unless File.exist?(backup_file)

      backup_as_hash = JSON.parse(File.read(backup_file))
      synchronize_with_local_cache!(backup_as_hash)
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
      synchronize_with_local_cache! get_features bootstrap_payload
      update_running_client!

      # reset Unleash.configuration.bootstrap_data to free up memory, as we will never use it again
      Unleash.configuration.bootstrap_config = nil
    end

    def build_segment_map(segments_array)
      return {} if segments_array.nil?

      segments_array.map{ |segment| [segment["id"], segment] }.to_h
    end

    # @param response_body [String]
    def get_features(response_body)
      response_hash = JSON.parse(response_body)

      if response_hash['version'] >= 1
        return { "features" => response_hash["features"], "segments" => build_segment_map(response_hash["segments"]) }
      end

      raise NotImplemented, "Version of features provided by unleash server" \
        " is unsupported by this client."
    end
  end
end
