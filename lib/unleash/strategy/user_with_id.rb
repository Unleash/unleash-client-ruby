require 'unleash/strategy/util'

module Unleash
  module Strategy
    class UserWithId < Base
      def name
        'userWithId'
      end

      # need: params[:user_ids], context.user_id,
      def is_enabled?(params = {}, context = nil)
        return false if params.nil? || params.size == 0
        return false if params[:user_ids].class.name != 'String'
        return false if context.class.name != 'Unleash::Context'

        params[:user_ids].split(",").contain?(context.user_id)
      end
    end
  end
end
