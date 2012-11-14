module CapDeployRightscale
  module Strategies
    class SwapRestartStrategy < BaseRestartStrategy
    
      def deploy
        servers = @rightscale.servers(CapDeployRightscale::Rightscale::Client::FLUSH_SERVER_CACHE)
        servers_in_deployment = servers.find_all { |server| server['deployment-id'] == @deployment_id}
        app_servers_in_deployment = servers_in_deployment.find_all { |server| server['tags'].include? @app_tag}
        load_balancers = @elb.describe_load_balancers
        load_balancer = load_balancers.find { |load_balancer| load_balancer[:load_balancer_name] == @load_balancer_name }
        live_app_servers = app_servers_in_deployment.find_all { |server| load_balancer[:instances].include? server['aws-id'] }
        inactive_app_servers = app_servers_in_deployment.find_all { |server| server['state'] == 'stopped' }
            
        raise 'Live app servers must match the instances in the load balancer' if load_balancer[:instances].length != live_app_servers.length
        raise 'Inactive app servers must be the same size as active app servers' if inactive_app_servers.length != live_app_servers.length
      
        # Deployment Process:
        #  1. Start up all inactive instances and add them to the load balancer
        #  2. Remove the old live instance from the load balancer and shut them down
        start_servers(inactive_app_servers)
        stop_servers(live_app_servers)
      end
    
      def start_servers(servers)
        servers.each do |server|
          puts "Starting Server: #{server['nickname']}"
          @rightscale.start_server(server['server-id'])
        end
        updated_servers = []
        servers.each do |server|
          updated_servers << wait_for_server_state(server['server-id'], 'operational', 4)
        end
        updated_servers.each do |server|
          puts "Adding Server: #{server['nickname']} to load balancer"
          @elb.register_instances_with_load_balancer(@load_balancer_name, server['aws-id'])
        end
      end
    
      def stop_servers(servers)
        servers.each do |server|
          puts "Removing Server: #{server['nickname']} from load balancer"
          @elb.deregister_instances_with_load_balancer(@load_balancer_name, server['aws-id'])
        end
        servers.each do |server|
          puts "Stopping Server: #{server['nickname']}"
          @rightscale.stop_server(server['server-id'])
        end
        servers.each do |server|
          wait_for_server_state(server['server-id'], 'stopped', 4)
        end
      end

    end
  end
end