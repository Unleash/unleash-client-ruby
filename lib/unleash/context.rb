module Unleash
  class Context
    ATTRS = [:app_name, :environment, :user_id, :session_id, :remote_address, :current_time].freeze

    attr_accessor(*[ATTRS, :properties].flatten)

    def initialize(params = {})
      raise ArgumentError, "Unleash::Context must be initialized with a hash." unless params.is_a?(Hash)

      self.app_name = value_for("appName", params, Unleash&.configuration&.app_name)
      self.environment = value_for("environment", params, Unleash&.configuration&.environment || "default")
      self.user_id = value_for("userId", params)&.to_s
      self.session_id = value_for("sessionId", params)
      self.remote_address = value_for("remoteAddress", params)
      self.current_time = value_for("currentTime", params, Time.now.utc.iso8601.to_s)

      properties = value_for("properties", params)
      self.properties = properties.is_a?(Hash) ? properties.transform_keys(&:to_sym) : {}
    end

    def to_s
      "<Context: user_id=#{@user_id},session_id=#{@session_id},remote_address=#{@remote_address},properties=#{@properties}" \
      ",app_name=#{@app_name},environment=#{@environment},current_time=#{@current_time}>"
    end

    def as_json(*_options)
      {
        appName: to_safe_value(self.app_name),
        environment: to_safe_value(self.environment),
        userId: to_safe_value(self.user_id),
        sessionId: to_safe_value(self.session_id),
        remoteAddress: to_safe_value(self.remote_address),
        currentTime: to_safe_value(self.current_time),
        properties: self.properties.transform_values{ |value| to_safe_value(value) }
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    def to_h
      ATTRS.map{ |attr| [attr, self.send(attr)] }.to_h.merge(properties: @properties)
    end

    # returns the value found for the key in the context, or raises a KeyError exception if not found.
    def get_by_name(name)
      normalized_name = underscore(name).to_sym

      if ATTRS.include? normalized_name
        self.send(normalized_name)
      else
        self.properties.fetch(normalized_name, nil) || self.properties.fetch(name.to_sym)
      end
    end

    def include?(name)
      normalized_name = underscore(name)
      return self.instance_variable_defined? "@#{normalized_name}" if ATTRS.include? normalized_name.to_sym

      self.properties.include?(normalized_name.to_sym) || self.properties.include?(name.to_sym)
    end

    private

    # Method to fetch values from hash for two types of keys: string in camelCase and symbol in snake_case
    def value_for(key, params, default_value = nil)
      params.values_at(key, key.to_sym, underscore(key), underscore(key).to_sym).compact.first || default_value
    end

    def to_safe_value(value)
      return nil if value.nil?

      if value.is_a?(Time)
        value.utc.iso8601
      else
        value.to_s
      end
    end

    # converts CamelCase to snake_case
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end
  end
end
