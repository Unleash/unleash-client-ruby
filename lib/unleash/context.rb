module Unleash

  class Context
    attr_accessor :user_id, :session_id, :remote_address, :properties

    def initialize(params = {})
      params_is_a_hash = params.is_a?(Hash)
      self.user_id    = fetch(params, 'userId')
      self.session_id = fetch(params, 'sessionId')
      self.remote_address = fetch(params, 'remoteAddress')
      self.properties =
        if params_is_a_hash && ( params.fetch(:properties, nil) || params.fetch('properties', nil) ).is_a?(Hash)
          fetch(params, 'properties', {})
        else
          {}
        end
    end

    def to_s
      "<Context: user_id=#{self.user_id},session_id=#{self.session_id},remote_address=#{self.remote_address},properties=#{self.properties}>"
    end

    private
    # Fetch key from hash. Try first with using camelCase, and if not found, try with snake case.
    # This way we are are idiomatically compliant with ruby, but still giving priority to the same
    # key names as in the other clients.
    def fetch(params, camelcase_key, default_ret = '')
      return default_ret unless params.is_a?(Hash)
      return params.fetch(camelcase_key, nil) || params.fetch(snakesym(camelcase_key), nil) || default_ret
    end

    # transform CamelCase to snake_case and make it a sym
    def snakesym(key)
      key.dup.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym
    end
  end
end