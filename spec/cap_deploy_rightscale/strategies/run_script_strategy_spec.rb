require 'spec_helper'

include RightscaleFakeweb

describe 'CapDeployRightscale::Strategies::RunScriptStrategy' do
  
  before(:each) do
    @credentials = CapDeployRightscale::Credentials.new
    @credentials.add_credential('rightscale', 'account', DUMMY_ACCOUNT_ID)
    @credentials.add_credential('rightscale', 'username', 'fake@example.com')
    @credentials.add_credential('rightscale', 'password', 'abc123')
    @credentials.save_file
    deployment_id = 'dummy'
    app_tag = 'dummy'
    script_id = 'dummy'
    @base_strategy = CapDeployRightscale::Strategies::RunScriptStrategy.new(deployment_id, app_tag, script_id)
  end
  
  after(:each) do
    @credentials.delete_file
  end
  
  it '#wait_for_server_state' do
    register_get_status

    status_href = 'https://my.rightscale.com/api/acct/1234/audit_entries/67895'
    @base_strategy.wait_for_script_state(status_href, 'completed', 1)
    # Should complete
  end
  
end