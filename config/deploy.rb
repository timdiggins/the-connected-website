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

#before "deploy:update_code", "deploy:git:pending"


# set  :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
# set :rails_revision, '339491a6b37722497ebafe9998e17507f47e8fd6'