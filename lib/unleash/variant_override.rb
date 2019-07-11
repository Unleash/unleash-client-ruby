module Unleash
  class VariantOverride
    attr_accessor :context_name, :values

    def initialize(context_name, values = [])
      self.context_name = context_name
      self.values = values || []

      validate
    end

    def to_s
      "<VariantOverride: context_name=#{self.context_name},values=#{self.values}>"
    end

    def matches_context?(context)
      raise ArgumentError, 'context must be of class Unleash::Context' unless context.class.name == 'Unleash::Context'

      context_value =
        case self.context_name
        when 'userId'
          context.user_id
        when 'sessionId'
          context.session_id
        when 'remoteAddress'
          context.remote_address
        else
          context.properties.fetch(self.context_name, nil)
        end

      Unleash.logger.debug "VariantOverride: context_name: #{context_name} context_value: #{context_value}"

      self.values.include? context_value.to_s
    end

    private

    def validate
      raise ArgumentError, 'context_name must be a String' unless self.context_name.is_a?(String)
      raise ArgumentError, 'values must be an Array of strings' unless self.values.is_a?(Array) \
          && self.values.reject{ |v| v.is_a?(String) }.empty?
    end
  end
end
