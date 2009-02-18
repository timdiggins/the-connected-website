set :default_stage, "production"

require 'capistrano/ext/multistage'
require 'spacesuit/recipes/multistage_patch'
require 'spacesuit/recipes/common'
require 'config/recipes/monit'

set :application, "wminarch"
set :rails_env, "production"
set :ssh_options, {:forward_agent => true}
set :use_sudo, false

default_run_options[:pty] = true
set :scm, "git"
set :branch, "wminarch"
set :repository,  "git://github.com/red56/the-connected-website.git"
set :keep_releases, 30
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

set :rails_revision, '79f55de9c5e3ff1f8d9e767c5af21ba31be4cfba' # Fri Sep 19 09:06:35 2008 -0500  -   From master branch

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |action|
    desc "#{action.to_s} is a noop"
    task action, :roles => :app do;end
  end
end

before "deploy:stop", "republic_services:stop"
before "deploy:restart", "republic_services:restart" 
after  "deploy:start",  "republic_services:start"