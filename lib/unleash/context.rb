module Unleash

  class Context
    attr_accessor :app_name, :environment, :user_id, :session_id, :remote_address, :properties

    def initialize(params = {})
      raise ArgumentError, "Unleash::Context must be initialized with a hash." unless params.is_a?(Hash)

      self.app_name    = params.values_at('appName', :app_name).compact.first || ( !Unleash.configuration.nil? ? Unleash.configuration.app_name : nil )
      self.environment = params.values_at('environment', :environment).compact.first || 'default'
      self.user_id    = params.values_at('userId', :user_id).compact.first || ''
      self.session_id = params.values_at('sessionId', :session_id).compact.first || ''
      self.remote_address = params.values_at('remoteAddress', :remote_address).compact.first || ''

      properties = params.values_at('properties', :properties).compact.first
      self.properties = properties.is_a?(Hash) ? properties : {}
    end

    def to_s
      "<Context: user_id=#{self.user_id},session_id=#{self.session_id},remote_address=#{self.remote_address},properties=#{self.properties}>"
    end
  end
end
