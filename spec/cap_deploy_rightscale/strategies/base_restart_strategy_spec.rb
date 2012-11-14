require 'spec_helper'

include RightscaleFakeweb

describe 'CapDeployRightscale::Strategies::BaseRestartStrategy' do
  
  before(:each) do
    @credentials = CapDeployRightscale::Credentials.new
    @credentials.add_credential('rightscale', 'account', DUMMY_ACCOUNT_ID)
    @credentials.add_credential('rightscale', 'username', 'fake@example.com')
    @credentials.add_credential('rightscale', 'password', 'abc123')
    @credentials.save_file
    rightscale = client = CapDeployRightscale::Rightscale::Client.new
    elb = nil
    load_balancer_name = 'dummy'
    deployment_id = 'dummy'
    app_tag = 'dummy'
    @base_strategy = CapDeployRightscale::Strategies::BaseRestartStrategy.new(rightscale, elb, load_balancer_name, deployment_id, app_tag)
  end
  
  after(:each) do
    @credentials.delete_file
  end
  
  it '#deploy' do
    expect {
      @base_strategy.deploy
    }.to raise_error(Exception)
  end
  
  it '#wait_for_server_state' do
    register_servers
    register_server_settings

    @base_strategy.wait_for_server_state('5678', 'operational', 1)
    # Should complete
  end
  
end