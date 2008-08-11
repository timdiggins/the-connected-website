set :default_stage, "production"

require 'capistrano/ext/multistage'
require 'spacesuit/recipes/multistage_patch'
require 'spacesuit/recipes/common'
require 'mongrel_cluster/recipes_2'

set :application, "republic"
set :rails_env, "production"
set :ssh_options, {:forward_agent => true}

default_run_options[:pty] = true
set :scm, "git"
set :branch, "master"
set :repository,  "git://github.com/red56/the-connected-website.git"
set :keep_releases, 30
set :git_enable_submodules, 1
set :rails_revision, 'eb4668b26ad4aacf79488d2bee553e9452971c35'