set :default_stage, "production"

require 'capistrano/ext/multistage'
require 'spacesuit/recipes/multistage_patch'
require 'spacesuit/recipes/common'
require 'mongrel_cluster/recipes_2'
require 'config/recipes/monit'

set :application, "republic"
set :rails_env, "production"
set :ssh_options, {:forward_agent => true}
set :use_sudo, false

default_run_options[:pty] = true
set :scm, "git"
set :branch, "master"
set :repository,  "git://github.com/red56/the-connected-website.git"
set :keep_releases, 30
set :git_enable_submodules, 1

set :rails_revision, 'd4eb3c0b7d13d3898c14d6ea7bfbc1853394f4e8' # Thu Sep 4 16:31:40 2008 +0200  -   From 2-1-stable branch
