module Unleash
  class Context
    ATTRS = [:app_name, :environment, :user_id, :session_id, :remote_address].freeze

    attr_accessor(*[ATTRS, :properties].flatten)

    def initialize(params = {})
      raise ArgumentError, "Unleash::Context must be initialized with a hash." unless params.is_a?(Hash)

      self.app_name    = value_for('appName', params, Unleash&.configuration&.app_name)
      self.environment = value_for('environment', params, Unleash&.configuration&.environment || 'default')
      self.user_id     = value_for('userId', params)
      self.session_id  = value_for('sessionId', params)
      self.remote_address = value_for('remoteAddress', params)

      properties = value_for('properties', params)
      self.properties = properties.is_a?(Hash) ? properties.transform_keys(&:to_sym) : {}
    end

    def to_s
      "<Context: user_id=#{@user_id},session_id=#{@session_id},remote_address=#{@remote_address},properties=#{@properties}" \
        ",app_name=#{@app_name},environment=#{@environment}>"
    end

    def get_by_name(name)
      normalized_name = underscore(name).to_sym

      if ATTRS.include? normalized_name
        self.send(normalized_name)
      else
        self.properties.fetch(normalized_name, nil) || self.properties.fetch(name.to_sym)
      end
    end

    private

    # Method to fetch values from hash for two types of keys: string in camelCase and symbol in snake_case
    def value_for(key, params, default_value = nil)
      params.values_at(key, key.to_sym, underscore(key), underscore(key).to_sym).compact.first || default_value
    end

    # converts CamelCase to snake_case
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end
  end
end
