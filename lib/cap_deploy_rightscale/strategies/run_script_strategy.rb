module CapDeployRightscale
  module Strategies
    class RunScriptStrategy
      
      include CapDeployRightscale::Strategies::WaitHelper
      
      def initialize(deployment_id, app_tag, script_id)
        @rightscale = CapDeployRightscale::Rightscale::Client.new
        @deployment_id = deployment_id.to_s
        @app_tag = app_tag
        @script_id = script_id
      end
    
      def execute
        servers = @rightscale.servers(CapDeployRightscale::Rightscale::Client::FLUSH_SERVER_CACHE)
        servers_in_deployment = servers.find_all { |server| server['deployment-id'] == @deployment_id}
        app_servers_in_deployment = servers_in_deployment.find_all { |server| server['tags'].include? @app_tag}
        live_app_servers = app_servers_in_deployment.find_all { |server| load_balancer[:instances].include? server['aws-id'] }
        
        # Deployment Process:
        #  1. Iterate over all current instances and run the specified script
        start_server_and_add_to_elb(inactive_app_servers.first)
        necessary_servers = live_app_servers.length - 1
        live_app_servers.each do |server|
          run_script(server)
        end
      end
    
      def run_script(server)
        puts "Executing Script #{@script_id} on Server: #{server['nickname']}"
        status_href = @rightscale.run_script(@server_id)
        wait_for_script_state(status_href, 'complete', 1)
      end
    
      def wait_for_script_state(status_href, desired_state, polling_wait_in_minutes)
        get_script_state_function = lambda do
          @rightscale.get_status(status_href)
        end
        check_script_state_function = lambda do |current_state|
          valid_state = current_state == desired_state
          puts "Waiting for script state to change from #{current_state} to #{desired_state}..." if not valid_state
          valid_state
        end
        wait_for_state(get_script_state_function, check_script_state_function, polling_wait_in_minutes)
      end

    end
  end
end