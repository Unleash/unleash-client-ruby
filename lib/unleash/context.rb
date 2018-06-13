module Unleash

  class Context
    attr_accessor :user_id, :session_id, :remote_address

    def initialize
      self.user_id = ''
      self.session_id = ''
      self.remote_address = ''
    end

    def to_s
      "<Context: user_id=#{self.user_id},session_id=#{self.session_id},remote_address=#{self.remote_address}>"
    end
  end
end