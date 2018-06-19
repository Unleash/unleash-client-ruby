module Unleash
  module Strategy
    class UserWithId < Base
      def name
        'userWithId'
      end

      # requires: params['userIds'], context.user_id,
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?('userIds')
        return false unless params.fetch('userIds', nil).is_a? String
        return false unless context.class.name == 'Unleash::Context'

        params['userIds'].split(",").map(&:strip).include?(context.user_id)
      end
    end
  end
end
