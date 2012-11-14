module CapDeployRightscale
  module Strategies
    class BaseRestartStrategy
      
      def initialize(deployment_id, load_balancer_name, app_tag)
        @rightscale = CapDeployRightscale::Rightscale::Client.new
        credentials = CapDeployRightscale::Credentials.new
        aws_access_key_id = credentials.get_credential('aws', 'aws_access_key_id')
        aws_secret_access_key = credentials.get_credential('aws', 'aws_secret_access_key')
        @elb = ::Rightscale::ElbInterface.new(aws_access_key_id, aws_secret_access_key)
        @deployment_id = deployment_id.to_s
        @load_balancer_name = load_balancer_name
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