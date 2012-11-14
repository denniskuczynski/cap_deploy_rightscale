
cset :aws_access_key_id { Capistrano::CLI.password_prompt "AWS Access Key ID: " }
cset :aws_secret_access_key { Capistrano::CLI.password_prompt "AWS Secret Access Key: " }

namespace :aws do
  
  desc "Store AWS Credentials on disk for ELB Operations"
  task :store_credentials do
    credentials = Credentials.new
    credentials.add_credential('aws', 'aws_access_key_id', aws_access_key_id)
    credentials.add_credential('aws', 'aws_secret_access_key', aws_secret_access_key)
    credentials.save_file
  end

  desc "Output AWS Load Balancers Table to Console"
  task :load_balancers do
    credentials = Credentials.new
    aws_access_key_id = credentials.add_credential('aws', 'aws_access_key_id')
    aws_secret_access_key = credentials.add_credential('aws', 'aws_secret_access_key')
    elb = Rightscale::ElbInterface.new(aws_access_key_id, aws_secret_access_key)
    load_balancers = elb.describe_load_balancers
    print_as_table(load_balancers)
  end

  def print_as_table(load_balancers)
    padding = 16
    padding_long = 48
    header = 'Name'.center(padding)
    header << 'DNS'.center(padding_long)
    header << 'Instances'.center(padding_long)
    puts header
    
    load_balancers.each do |load_balancer|
      load_balancer_name = load_balancer[:load_balancer_name]
      dns_name = load_balancer[:dns_name]
      instances = load_balancer[:instances].inspect
      load_balancer_info = load_balancer_name.center(padding)
      load_balancer_info << dns_name.center(padding_long)
      load_balancer_info << instances.center(padding_long)
      puts load_balancer_info
    end
  end

end
