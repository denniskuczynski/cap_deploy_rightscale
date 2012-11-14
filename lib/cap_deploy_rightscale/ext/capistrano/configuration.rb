module Capistrano
  class Configuration
    module Tags
      
      # Associate a tag in a specific deployment with a role
      # e.g:
      #   tag "x99:role=app", :app, :deployment => 45678
      def tag(which, *args)
        rightscale = Rightscale::Client.new
        servers = rightscale.servers(CapDeployRightscale::Rightscale::Client::USE_SERVER_CACHE)
        
        deployment = args.last[:deployment]
        active_servers = filter_active_servers_in_deployment(servers, deployment.to_s)
        active_servers.each do |server|
          if server['tags'].include?(which)
            logger.info  "Configured Server: #{server['dns-name']}, #{args.inspect}"
            server(server['dns-name'], *args)
          end
        end
      end
      
      def filter_active_servers_in_deployment(servers, deployment)
        servers.find_all do |server| 
          server['deployment-id'] == deployment and server['state'] == 'operational'
        end
      end
      
    end
      
    include Tags

  end
end