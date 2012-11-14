module CapDeployRightscale
  module Strategies
    class BaseRestartStrategy
      
      def initialize(rightscale, elb, load_balancer_name, deployment_id, app_tag)
        @rightscale = rightscale
        @elb = elb
        @load_balancer_name = load_balancer_name
        @deployment_id = deployment_id.to_s
        @app_tag = app_tag
      end
      
      def deploy
        raise Exception "BaseStrategy#deploy should be overidden by subclass"
      end
      
      def wait_for_server_state(server_id, desired_state, polling_wait_in_minutes)
        get_server_state_function = lambda do
          servers = @rightscale.servers(CapDeployRightscale::Rightscale::Client::FLUSH_SERVER_CACHE)
          server = servers.find { |server| server['server-id'] == server_id }
          server
        end
        check_server_state_function = lambda do |server|
          current_state = server['state']
          valid_state = current_state == desired_state
          puts "Waiting for #{server['nickname']}'s state to change from #{current_state} to #{desired_state}..." if not valid_state
          valid_state
        end
        wait_for_state(get_server_state_function, check_server_state_function, polling_wait_in_minutes)
      end
      
      protected
      
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