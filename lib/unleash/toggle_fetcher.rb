require 'unleash/configuration'
require 'net/http'
require 'json'
require 'thread'

module Unleash

  class ToggleFetcher
    attr_accessor :toggle_cache, :toggle_lock, :toggle_resource, :etag

    def initialize
      self.toggle_lock = Mutex.new
      self.toggle_resource = ConditionVariable.new
      self.toggle_cache = nil
      self.etag = nil

      # start by fetching synchronously, and failing back to reading the backup file.
      begin
        fetch
      rescue Exception => e
        Unleash.logger.warn "ToggleFetcher was unable to fetch from the network, attempting to read from backup file."
        read!
        raise e
      end

      #once that is in place, start the fetcher loop
      self.start_periodic_fetcher_thread
    end

    def start_periodic_fetcher_thread
      periodic_fetcher_thread = Thread.new do
        loop do
          Unleash.logger.debug "periodic_fetcher_thread sleeping for #{Unleash.configuration.refresh_interval}"
          sleep Unleash.configuration.refresh_interval

          begin
            Unleash.logger.debug "periodic_fetcher_thread (fetching):"
            remote_toggles = fetch()
          rescue Exception => e
            Unleash.logger.error "An exception happened when retrieving features from the Unleash Server", e
          end
        end
      end
    end

    def toggles
      self.toggle_lock.synchronize do
        # wait for resource, only if it is null
        self.toggle_resource.wait(self.toggle_lock) if self.toggle_cache.nil?
        return self.toggle_cache
      end
    end

    # rename to refresh_from_server!  ??
    def fetch
      Unleash.logger.debug "fetch()"
      Unleash.logger.debug "ETag: #{self.etag}" unless self.etag.nil?

      uri = URI(Unleash.configuration.fetch_toggles_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = Unleash.configuration.timeout # in seconds
      http.read_timeout = Unleash.configuration.timeout # in seconds
      request = Net::HTTP::Get.new(uri.request_uri)
      request['If-None-Match'] = self.etag unless self.etag.nil?

      response = http.request(request)

      if response.code == '304'
        Unleash.logger.debug "No changes according to the unleash server, nothing to do."
        return
      end

      if response.code != '200'
        raise IOError, "unable to fetch features from the unleash server." \
         " It returned a non 200 HTTP result."
      end

      self.etag = response['ETag']
      begin
        response_hash = JSON.parse(response.body)
      rescue JSON::ParserError => e
        Unleash.logger.error "invalid JSON returned by unleash server, attempting to read from backup file."
        raise e
      end

      if response_hash['version'] != 1
        raise NotImplemented, "version of features provided by unleash server" \
          " is unsupported by this client."
      else
        features = response_hash['features']
      end

      # always synchronize with the local cache when fetching:
      if self.toggle_cache != features
        self.toggle_lock.synchronize do
          self.toggle_cache = features
        end

        # notify all threads waiting for this resource to no longer wait
        self.toggle_resource.broadcast
      end

      Unleash.logger.info "flush changes to running client variable"
      update_client

      Unleash.logger.info "Saved to toggle cache, will save to disk now"
      save!
    end

    private
    def update_client
      if Unleash.toggles != self.toggles
        Unleash.logger.info "Updating toggles to main client, there has been a change in the server."
        Unleash.toggles = self.toggles
      end
    end

    def backup_file_exists?
      File.exists?(backup_file)
    end

    def save!
      begin
        file = File.open(Unleash.configuration.backup_file, "w")

        self.toggle_lock.synchronize do
          file.write(self.toggle_cache.to_json)
        end
      # rescue IOError => e
        # some error occur.
        # raise e
      rescue Exception => e
        Unleash.logger.error "Unable to save backup file."
        # this is not really the end of the world. consider swallowing the exception.
        raise e
      ensure
        file.close unless file.nil?
      end
    end

    def read!
      Unleash.logger.info "read!()"
      backup_file = Unleash.configuration.backup_file
      return nil unless File.exists?(backup_file)

      begin
        file = File.open(backup_file, "r")
        line_cache = ""
        file.each_line do |line|
          line_cache += line
        end

        backup_as_hash = JSON.parse(line_cache)

        self.toggle_lock.synchronize do
          self.toggle_cache = backup_as_hash
        end
      rescue IOError => e
        # some error occur.
      rescue JSON::ParserError => e
        Unleash.logger.error "Unable to parse JSON from existing backup_file."
      ensure
        file.close unless file.nil?
      end
    end
  end
end