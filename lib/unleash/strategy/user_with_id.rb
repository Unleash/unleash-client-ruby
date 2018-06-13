module Unleash
  module Strategy
    class UserWithId < Base
      def name
        'userWithId'
      end

      # need: params['userIds'], context.user_id,
      def is_enabled?(params = {}, context = nil)
        return false if params.nil? || params.size == 0
        return false if params['userIds'].class.name != 'String'
        return false if context.class.name != 'Unleash::Context'

        params['userIds'].split(",").map(&:strip).include?(context.user_id)
      end
    end
  end
end
