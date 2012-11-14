module CapDeployRightscale
  module Strategies
    class RollingRestartStrategy < BaseRestartStrategy
    
      def deploy
        servers = @rightscale.servers(CapDeployRightscale::Rightscale::Client::FLUSH_SERVER_CACHE)
        servers_in_deployment = servers.find_all { |server| server['deployment-id'] == @deployment_id}
        app_servers_in_deployment = servers_in_deployment.find_all { |server| server['tags'].include? @app_tag}
        load_balancers = @elb.describe_load_balancers
        load_balancer = load_balancers.find { |load_balancer| load_balancer[:load_balancer_name] == @load_balancer_name }
        live_app_servers = app_servers_in_deployment.find_all { |server| load_balancer[:instances].include? server['aws-id'] }
        inactive_app_servers = app_servers_in_deployment.find_all { |server| server['state'] == 'stopped' }
      
        raise 'Live app servers must match the instances in the load balancer' if load_balancer[:instances].length != live_app_servers.length
        raise 'There must be at least one inactive app server for rolling deploy' if inactive_app_servers.length < 1
      
        # Deployment Process:
        #  1. Start up an inactive instance to maintain capacity
        #  2. Iterate over all current instances and restart them
        #  3. Don't start up the last instance to preserve original capacity
        start_server_and_add_to_elb(inactive_app_servers.first)
        necessary_servers = live_app_servers.length - 1
        live_app_servers.each do |server|
          remove_from_elb_and_stop_server(server)
          if necessary_servers > 0
            start_server_and_add_to_elb(server)
            necessary_servers = necessary_servers - 1
          end
        end
      end
    
      def start_server_and_add_to_elb(server)
        puts "Starting Server: #{server['nickname']}"
        @rightscale.start_server(server['server-id'])
        updated_server = wait_for_server_state(server['server-id'], 'operational', 4)
        puts "Adding Server: #{server['nickname']} to load balancer"
        @elb.register_instances_with_load_balancer(@load_balancer_name, updated_server['aws-id'])
      end
    
      def remove_from_elb_and_stop_server(server)
        puts "Removing Server: #{server['nickname']} from load balancer"
        @elb.deregister_instances_with_load_balancer(@load_balancer_name, server['aws-id'])
        puts "Stopping Server: #{server['nickname']}"
        @rightscale.stop_server(server['server-id'])
        updated_server = wait_for_server_state(server['server-id'], 'stopped', 4)
      end

    end
  end
end