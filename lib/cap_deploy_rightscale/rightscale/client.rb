module CapDeployRightscale
  module Rightscale
    class Client
      
      FLUSH_SERVER_CACHE = true
      USE_SERVER_CACHE = false
    
      SERVERS_CACHE_PATH  = './.cap_deploy_rightscale_server_cache.json'
    
      def initialize()
        @credentials = Credentials.new
        @account_id = @credentials.get_credential('rightscale', 'account')
        @username = @credentials.get_credential('rightscale', 'username')
        @password = @credentials.get_credential('rightscale', 'password')
        @cookie = @credentials.get_credential('rightscale', 'cookie')
      end
    
      def login()
        raise Exception 'Username/Password must be stored in credentials to login' if not @username or not @password
        @cookie = CapDeployRightscale::Rightscale::Operations.login(@account_id, @username, @password, @cookie)
        if @cookie
          @credentials.add_credential('rightscale', 'cookie', @cookie)
          @credentials.save_file
          true
        else
          false
        end
      end
    
      def servers(flush_cache=false)
        if File.exist?(SERVERS_CACHE_PATH) and not flush_cache
          return JSON.parse(File.open(SERVERS_CACHE_PATH, "r").read)
        end
      
        servers = CapDeployRightscale::Rightscale::Operations.servers(@account_id, @cookie)
        File.open(SERVERS_CACHE_PATH, 'w') {|f| f.write(servers.to_json) }
        servers
      end
    
      def start_server(server_id)
        CapDeployRightscale::Rightscale::Operations.start_server(@account_id, @cookie, server_id)
      end
    
      def stop_server(server_id)
        CapDeployRightscale::Rightscale::Operations.stop_server(@account_id, @cookie, server_id)
      end

      def run_script(server_id, script_id, parameters = {})
        status_id = CapDeployRightscale::Rightscale::Operations.run_script(@account_id, @cookie, server_id, script_id, parameters)
        status_id
      end
      
       def get_status(status_id)
        status = CapDeployRightscale::Rightscale::Operations.get_status(@account_id, @cookie, status_id)
        status
      end

    end
  end
end