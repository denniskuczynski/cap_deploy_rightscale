require 'spec_helper'

include RightscaleFakeweb

describe 'CapDeployRightscale::Rightscale::Client' do
  
  DUMMY_ACCOUNT_ID = '1234'
  DUMMY_SERVER_ID = '5678'
  DUMMY_STATUS_ID = '2468'
  DUMMY_SCRIPT_ID = '1357'
  DUMMY_STATUS_HREF = 'https://my.rightscale.com/api/acct/1234/audit_entries/67895'
  
  describe 'without credentials' do
    it '#initialize' do
      client = CapDeployRightscale::Rightscale::Client.new
      client.should_not be_nil
    end
    
    it '#login' do
      client = CapDeployRightscale::Rightscale::Client.new
      expect {
        client.login
      }.to raise_error(Exception)
    end
  end
  
  describe 'with credentials' do
    before(:each) do
      @credentials = CapDeployRightscale::Credentials.new
      @credentials.add_credential('rightscale', 'account', DUMMY_ACCOUNT_ID)
      @credentials.add_credential('rightscale', 'username', 'fake@example.com')
      @credentials.add_credential('rightscale', 'password', 'abc123')
      @credentials.save_file
    end
    
    after(:each) do
      @credentials.delete_file
    end

    it '#initialize' do
      client = CapDeployRightscale::Rightscale::Client.new    
      client.should_not be_nil
    end

    describe '#login' do
      it 'on_success' do
        register_login_success

        client = CapDeployRightscale::Rightscale::Client.new    
        client.login.should eq(true)
      end
      
      it 'on_failure' do
        register_login_failure

        client = CapDeployRightscale::Rightscale::Client.new    
        client.login.should eq(false)
      end
    end
    
    describe 'when logged in' do
      before(:each) do
        register_login_success
        @client = CapDeployRightscale::Rightscale::Client.new    
        @client.login
      end
      
      after(:each) do
        if File.exists?(CapDeployRightscale::Rightscale::Client::SERVERS_CACHE_PATH)
          File.delete(CapDeployRightscale::Rightscale::Client::SERVERS_CACHE_PATH)
        end
      end
      
      describe '#servers' do
        it 'on_success' do
          register_servers
          register_server_settings

          servers = @client.servers(true)
          servers.length.should eq(1)
          servers[0]['nickname'].should eq('dev v13')
          servers[0]['dns-name'].should eq('ec2-54-242-135-213.compute-1.amazonaws.com')
          
          File.exists?(CapDeployRightscale::Rightscale::Client::SERVERS_CACHE_PATH).should eq(true)
        end
      end
      
      describe '#start_server' do
        it 'on_success' do
          register_start_server

          @client.start_server(DUMMY_SERVER_ID)
        end
      end
      
      describe '#stop_server' do
        it 'on_success' do
          register_stop_server

          @client.stop_server(DUMMY_SERVER_ID)
        end
      end
      
      describe '#run_script' do
        it 'on_success' do
          register_run_script

          status_href = @client.run_script(DUMMY_SERVER_ID, DUMMY_SCRIPT_ID)
          status_href.should eq(DUMMY_STATUS_HREF)
        end
      end
      
      describe '#get_status' do
        it 'on_success' do
          register_get_status

          status = @client.get_status(DUMMY_STATUS_HREF)
          status.should eq('completed')
        end
      end
    end    
  end
    
end