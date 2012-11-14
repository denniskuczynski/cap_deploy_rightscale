require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/cap_deploy_rightscale.rb', __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each  do |f|
  require f
end

require 'fakeweb'
FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.clean_registry
  end

end
