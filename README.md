# CapDeployRightscale

A library to script Rightscale deployments using Capistrano.

## Installation

Add these lines to your application's Gemfile:

    gem 'capistrano'
    gem 'cap_deploy_rightscale', :git => 'https://github.com/denniskuczynski/cap_deploy_rightscale.git'

## Usage

Run the following script to setup Capistrano:

    bundle exec capify

This will create a file /config/deploy.rb

Mine looks like this:

```ruby
set :stages, %w(dev production)
set :default_stage, "dev"
require 'capistrano/ext/multistage'

require 'cap_deploy_rightscale'
require 'cap_deploy_rightscale/recipes'

set :application, "sample_application_"

set :repository,  "https://example_repo_path.git"
set :scm, :git

set :user, "root"
set :deploy_to, "/home/webapps/#{application}"
```

Since I'm using the multistage extension, I've defined my deploy script in /config/deploy/dev.rb:

```ruby
DEPLOYMENT_ID = 1234
LOAD_BALANCER_NAME = 'dev'
APP_TAG = 'ns:role=app'

# Associate Rightscale Tags with Server Roles
#
# This will initialize Capistrano servers with the specified roles using
# 'operational' servers from the disk cache.  To update the disk cache, run cap rightscale:servers.
#
# Standard Capistrano tasks can then be run on those roles.
tag APP_TAG, :app, :deployment => DEPLOYMENT_ID

namespace :rightscale do
  desc "Rightscale Deploy"
  before 'rightscale:deploy', 'rightscale:login'
  task :deploy do
    strategy = CapDeployRightscale::Strategies::RollingRestartStrategy.new(DEPLOYMENT_ID, LOAD_BALANCER_NAME, APP_TAG)
    strategy.deploy
  end
end
```

## Storing Rightscale and AWS Credentials

Currently this gem will just store your credentials on disk in the file: .cap_deploy_rightscale_credentials.json

* NOTE: This is not very secure!

To initialize your credentials you can run the following cap commands:

    bundle exec cap rightscale:store_credentials
    bundle exec cap rightscale:login    # To check login credentials
    bundle exec cap rightscale:servers  # To see a table of servers in Rightscale

    bundle exec cap aws:store_credentials
    bundle exec cap aws:load_balancers  # To see a table of load balancers in AWS

Be sure to add the following files to your .gitignore file so not to accidentally check in the credentials:

    .cap_deploy_rightscale_credentials.json
    .cap_deploy_rightscale_server_cache.json

## Deploying

See the code for the different default scripts in the CapDeployRightscale::Strategies module.

The example deploy.rb file above will use CapDeployRightscale::Strategies::RollingRestartStrategy to restart all app servers when running:

    bundle exec cap rightscale:deploy
