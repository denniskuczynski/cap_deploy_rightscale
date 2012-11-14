module RightscaleFakeweb
  
  def register_login_success
    FakeWeb.register_uri(:any, %r|https://fake%40example.com:abc123@my.rightscale.com/api/acct/1234/login$|, :status => ["204", ""], 'set-cookie'.to_sym => "COOKIE")
  end
  
  def register_login_failure
    FakeWeb.register_uri(:any, %r|https://fake%40example.com:abc123@my.rightscale.com/api/acct/1234/login$|, :status => ["401", "Unauthorized"])
  end
  
  def register_servers
    servers_xml_path = File.expand_path(File.dirname(__FILE__) + "/../../spec/cap_deploy_rightscale/rightscale/example_xml/servers.xml")
    FakeWeb.register_uri(:any, %r|https://my.rightscale.com/api/acct/1234/servers$|, :body => File.read(servers_xml_path))
  end
  
  def register_server_settings
    server_settings_xml_path = File.expand_path(File.dirname(__FILE__) + "/../../spec/cap_deploy_rightscale/rightscale/example_xml/server_settings.xml")
    FakeWeb.register_uri(:any, %r|https://my.rightscale.com/api/acct/1234/servers/5678/settings$|, :body => File.read(server_settings_xml_path))
  end
  
  def register_start_server
    FakeWeb.register_uri(:any, %r|https://my.rightscale.com/api/acct/1234/servers/5678/start$|, :body => '')
  end
  
  def register_stop_server
    FakeWeb.register_uri(:any, %r|https://my.rightscale.com/api/acct/1234/servers/5678/stop$|, :body => '')
  end
  
  def register_run_script
    FakeWeb.register_uri(:any, %r|https://my.rightscale.com/api/acct/1234/servers/5678/run_script$|,  :status => ["201", "Created"], :location => 'https://my.rightscale.com/api/acct/1234/audit_entries/67895')
  end
  
  def register_get_status
    get_status_xml_path = File.expand_path(File.dirname(__FILE__) + "/../../spec/cap_deploy_rightscale/rightscale/example_xml/get_status.xml")
    FakeWeb.register_uri(:any, %r|https://my.rightscale.com/api/acct/1234/audit_entries/67895$|, :body => File.read(get_status_xml_path))
  end

end
