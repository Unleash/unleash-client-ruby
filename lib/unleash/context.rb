module Unleash

  class Context
    attr_accessor :user_id, :session_id, :remote_address

    def initialize(params = {})
      params_is_a_hash = params.is_a? Hash
      self.user_id    = params_is_a_hash ? params.fetch(:user_id, '') : ''
      self.session_id = params_is_a_hash ? params.fetch(:session_id, '') : ''
      self.remote_address = params_is_a_hash ? params.fetch(:remote_address, '') : ''
    end

    def to_s
      "<Context: user_id=#{self.user_id},session_id=#{self.session_id},remote_address=#{self.remote_address}>"
    end
  end
end