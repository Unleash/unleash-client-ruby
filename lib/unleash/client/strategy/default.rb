module Unleash
  module Client
    module Strategy
      class Default
        def is_enabled?(params = {})
          true
        end
      end
    end
  end
end