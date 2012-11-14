# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cap_deploy_rightscale/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dennis Kuczynski"]
  gem.email         = ["dennis.kuczynski@gmail.com"]
  gem.description   = %q{A library to script Rightscale deployments using Capistrano.}
  gem.summary       = %q{A library to script Rightscale deployments using Capistrano.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cap_deploy_rightscale"
  gem.require_paths = ["lib"]
  gem.version       = CapDeployRightscale::VERSION
  
  gem.add_dependency "capistrano"
  gem.add_dependency "nokogiri"
  gem.add_dependency "right_aws"
  gem.add_dependency "json"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "fakeweb"
end
