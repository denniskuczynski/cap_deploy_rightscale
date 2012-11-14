
cset :rightscale_account { Capistrano::CLI.password_prompt "Rightscale Account: " }
cset :rightscale_username { Capistrano::CLI.password_prompt "Rightscale Username: " }
cset :rightscale_password { Capistrano::CLI.password_prompt "Rightscale Password: " }

namespace :rightscale do
  
  desc "Store AWS Credentials on disk for ELB Operations"
  task :store_credentials do
    credentials = Credentials.new
    credentials.add_credential('rightscale', 'account', rightscale_account)
    credentials.add_credential('rightscale', 'username', rightscale_username)
    credentials.add_credential('rightscale', 'password', rightscale_password)
    credentials.save_file
  end

  desc "Login to Rightscale"
  task :login do
    client = CapDeployRightscale::Rightscale::Client.new
    ret_val = client.login
    if ret_val
      puts "Successfully logged into Rightscale"
    else
      puts "Error logging into Rightscale"
    end
  end

  desc "Rightscale List Servers"
  task :servers do
    credentials = Credentials.new
    rightscale_account = credentials.get_credential('rightscale', 'account')
    client = CapDeployRightscale::Rightscale::Client.new(rightscale_account)
    servers = client.servers(CapDeployRightscale::Rightscale::Client::FLUSH_SERVER_CACHE)
    print_as_table(servers)
  end
    
  def print_as_table(servers)
    padding = 15
    padding_long = 45
    header = 'Deployment'.center(padding)
    header << 'Server'.center(padding)
    header << 'AWS ID'.center(padding)
    header << 'Nickname'.center(padding)
    header << 'State'.center(padding)
    header << 'DNS'.center(padding_long)
    header << 'Tags'.center(padding_long)
    puts header

    servers = servers.sort { |a, b| a['deployment-id'] <=> b['deployment-id'] }
    last_deployment_id = nil
    servers.each do |server|
      puts "" if last_deployment_id and server['deployment-id'] != last_deployment_id
      last_deployment_id = server['deployment-id']

      server_info = server['deployment-id'].center(padding)
      server_info << server['server-id'].center(padding)
      server_info << server['aws-id'].center(padding)
      server_info << server['nickname'].center(padding)
      server_info << server['state'].center(padding)
      server_info << server['dns-name'].center(padding_long)
      server_info << server['tags'].inspect.center(padding_long)
      puts server_info        
    end
  end

end
