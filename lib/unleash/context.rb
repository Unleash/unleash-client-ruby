module Unleash
  class Context
    attr_accessor :app_name, :environment, :user_id, :session_id, :remote_address, :properties

    def initialize(params = {})
      raise ArgumentError, "Unleash::Context must be initialized with a hash." unless params.is_a?(Hash)

      self.app_name    = value_for('appName', params, Unleash&.configuration&.app_name)
      self.environment = value_for('environment', params, Unleash&.configuration&.environment || 'default')
      self.user_id     = value_for('userId', params)
      self.session_id  = value_for('sessionId', params)
      self.remote_address = value_for('remoteAddress', params)

      properties = value_for('properties', params)
      self.properties = properties.is_a?(Hash) ? properties : {}
    end

    def to_s
      "<Context: user_id=#{self.user_id},session_id=#{self.session_id},remote_address=#{self.remote_address},properties=#{self.properties}>"
    end

    private

    # Method to fetch values from hash for two types of keys: string in camelCase and symbol in snake_case
    def value_for(key, params, default_value = '')
      params.values_at(key, underscore(key).to_sym).compact.first || default_value
    end

    # converts CamelCase to snake_case
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end
  end
end
