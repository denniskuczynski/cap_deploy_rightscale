module CapDeployRightscale
  module Strategies
    module WaitHelper
      
      def wait_for_state(get_current_state_function, check_state_function, polling_wait_in_minutes)
        while true
          current_state = get_current_state_function.call
          if check_state_function.call(current_state)
            return current_state
          else
            sleep(60 * polling_wait_in_minutes)
          end
        end
      end

    end
  end
end