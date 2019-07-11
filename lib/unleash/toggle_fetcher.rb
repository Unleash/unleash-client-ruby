require 'unleash/configuration'
require 'net/http'
require 'json'
require 'thread'

module Unleash

  class ToggleFetcher
    attr_accessor :toggle_cache, :toggle_lock, :toggle_resource, :etag, :retry_count

    def initialize
      self.etag = nil
      self.toggle_cache = nil
      self.toggle_lock = Mutex.new
      self.toggle_resource = ConditionVariable.new
      self.retry_count = 0

      # start by fetching synchronously, and failing back to reading the backup file.
      begin
        fetch
      rescue Exception => e
        Unleash.logger.warn "ToggleFetcher was unable to fetch from the network, attempting to read from backup file."
        Unleash.logger.debug "Exception Caught: #{e}"
        read!
      end

      # once initialized, somewhere else you will want to start a loop with fetch()
    end

    def toggles
      self.toggle_lock.synchronize do
        # wait for resource, only if it is null
        self.toggle_resource.wait(self.toggle_lock) if self.toggle_cache.nil?
        return self.toggle_cache
      end
    end

    # rename to refresh_from_server!  ??
    # TODO: should simplify by moving uri / http initialization elsewhere
    def fetch
      Unleash.logger.debug "fetch()"
      Unleash.logger.debug "ETag: #{self.etag}" unless self.etag.nil?

      uri = URI(Unleash.configuration.fetch_toggles_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = Unleash.configuration.timeout # in seconds
      http.read_timeout = Unleash.configuration.timeout # in seconds

      headers = (Unleash.configuration.get_http_headers || {}).dup
      headers['Content-Type'] = 'application/json'
      headers['If-None-Match'] = self.etag unless self.etag.nil?

      request = Net::HTTP::Get.new(uri.request_uri, headers)

      response = http.request(request)

      Unleash.logger.debug "No changes according to the unleash server, nothing to do." if response.code == '304'
      return if response.code == '304'

      raise IOError, "Unleash server returned a non 200/304 HTTP result." if response.code != '200'

      self.etag = response['ETag']
      response_hash = JSON.parse(response.body)

      if response_hash['version'] == 1
        features = response_hash['features']
      else
        raise NotImplemented, "Version of features provided by unleash server" \
          " is unsupported by this client."
      end

      # always synchronize with the local cache when fetching:
      synchronize_with_local_cache!(features)

      Unleash.logger.info "Flush changes to running client variable"
      update_client!

      Unleash.logger.info "Saved to toggle cache, will save to disk now"
      save!
    end

    def save!
      begin
        backup_file = Unleash.configuration.backup_file
        backup_file_tmp = "#{backup_file}.tmp"

        self.toggle_lock.synchronize do
          file = File.open(backup_file_tmp, "w")
          file.write(self.toggle_cache.to_json)
          File.rename(backup_file_tmp, backup_file)
        end
      rescue Exception => e
        # This is not really the end of the world. Swallowing the exception.
        Unleash.logger.error "Unable to save backup file. Exception thrown #{e.class}:'#{e}'"
        Unleash.logger.error "stacktrace: #{e.backtrace}"
      ensure
        file.close if defined?(file) && ! file.nil?
        self.toggle_lock.unlock if self.toggle_lock.locked?
      end
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

    def update_client!
      if Unleash.toggles != self.toggles
        Unleash.logger.info "Updating toggles to main client, there has been a change in the server."
        Unleash.toggles = self.toggles
      end
    end

    def read!
      Unleash.logger.debug "read!()"
      return nil unless File.exist?(Unleash.configuration.backup_file)

      begin
        file = File.new(Unleash.configuration.backup_file, "r")
        file_content = file.read

        backup_as_hash = JSON.parse(file_content)
        synchronize_with_local_cache!(backup_as_hash)
        update_client!
      rescue IOError => e
        Unleash.logger.error "Unable to read the backup_file."
      rescue JSON::ParserError => e
        Unleash.logger.error "Unable to parse JSON from existing backup_file."
      rescue Exception => e
        Unleash.logger.error "Unable to extract valid data from backup_file. Exception thrown", e
      ensure
        file.close unless file.nil?
      end
    end
  end
end
