
require 'capistrano'
require 'nokogiri'
require 'right_aws'
require 'json'
require "net/https"
require "uri"

require "cap_deploy_rightscale/version"
require "cap_deploy_rightscale/credentials"
require "cap_deploy_rightscale/ext/capistrano/configuration"
require "cap_deploy_rightscale/rightscale/client"
require "cap_deploy_rightscale/rightscale/operations"
require "cap_deploy_rightscale/strategies/base_restart_strategy"
require "cap_deploy_rightscale/strategies/rolling_restart_strategy"
require "cap_deploy_rightscale/strategies/swap_restart_strategy"

module CapDeployRightscale
end
