module CapDeployRightscale
  module Rightscale
    class Operations

      RIGHTSCALE_ACCOUNT_PATH_PREFIX = 'https://my.rightscale.com/api/acct'
      RIGHTSCALE_API_VERSION = 1.0
        
      def self.login(account_id, username, password, cookie)
        response = execute_http_request(:get, "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/login", nil, username, password)
        if response.code.to_i == 204
          cookie = response['set-cookie']
          cookie
        else
          nil
        end
      end
    
      def self.servers(account_id, cookie)
        servers = []
        response = execute_http_request(:get, "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/servers", cookie)
        xml_doc  = Nokogiri::XML(response.body)
        xml_doc.xpath('/servers/server').each do |server_node|
          server = {}
          server['nickname'] = server_node.xpath('nickname').text()
          server['href'] = server_node.xpath('href').text()
          server['deployment-href'] = server_node.xpath('deployment-href').text()
          server['state'] = server_node.xpath('state').text()
          server['tags'] = []
          server_node.xpath('tags/tag').each do |tag_node|
              server['tags'] << tag_node.xpath('name').text()
          end
          server['server-id'] = extract_id(server['href'])
          server['deployment-id'] = extract_id(server['deployment-href'])
          server = server.merge(server_settings(server['href'], cookie))
          servers << server
        end
        servers
      end
    
      def self.server_settings(href, cookie)
        response = execute_http_request(:get, "#{href}/settings", cookie)
        xml_doc = Nokogiri::XML(response.body)
        settings_node = xml_doc.xpath('/settings').first
        settings = {}
        if settings_node
          settings['ec2-instance-type'] = settings_node.xpath('ec2-instance-type').text()
          settings['ec2-availability-zone'] = settings_node.xpath('ec2-availability-zone').text()
          settings['dns-name'] = settings_node.xpath('dns-name').text()
          settings['aws-id'] = settings_node.xpath('aws-id').text()
        end
        settings
      end
    
      def self.start_server(account_id, cookie, server_id)
        execute_http_request(:post, "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/servers/#{server_id}/start", cookie)
      end

      def self.stop_server(account_id, cookie, server_id)
        execute_http_request(:post, "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/servers/#{server_id}/stop", cookie)
      end
      
      def self.run_script(account_id, cookie, server_id, script_id, parameters = {})
        parameters['right_script'] = "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/right_scripts/#{script_id}"
        execute_http_request(:post, "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/servers/#{server_id}/run_script", cookie, parameters)
      end
      
      def self.get_status(account_id, cookie, status_id)
        execute_http_request(:get, "#{RIGHTSCALE_ACCOUNT_PATH_PREFIX}/#{account_id}/statuses/#{status_id}", cookie)
      end
    
      def self.execute_http_request(method, url, cookie, username=nil, password=nil, parameters = nil)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
        request = nil
        if method == :get
          request = Net::HTTP::Get.new(uri.request_uri)
        else
          request = Net::HTTP::Post.new(uri.request_uri)
        end
        if username and password
          request.basic_auth(username, password)
        end
        request["X-API-VERSION"] = RIGHTSCALE_API_VERSION
        request["Cookie"] = cookie if cookie
        if parameters
          parameters.each do |key, value|
            request[key] = value
          end
        end
        response = http.request(request)
        response
      end
    
      # Extract the REST item ID from the end of the URL
      def self.extract_id(href)
        href[href.rindex('/')+1, href.length]
      end
    
    end
  end
end