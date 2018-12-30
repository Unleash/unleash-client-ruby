module Unleash

  class Context
    attr_accessor :user_id, :session_id, :remote_address, :properties

    def initialize(params = {})
      params_is_a_hash = params.is_a?(Hash)
      self.user_id    = params_is_a_hash ? params.fetch('userId', '') : ''
      self.session_id = params_is_a_hash ? params.fetch('sessionId', '') : ''
      self.remote_address = params_is_a_hash ? params.fetch('remoteAddress', '') : ''
      self.properties = params_is_a_hash && params[:properties].is_a?(Hash) ? params.fetch(:properties, {}) : {}
    end

    def to_s
      "<Context: user_id=#{self.user_id},session_id=#{self.session_id},remote_address=#{self.remote_address},properties=#{self.properties}>"
    end
  end
end