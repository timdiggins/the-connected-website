set :default_stage, "production"

require 'capistrano/ext/multistage'
require 'spacesuit/recipes/multistage_patch'
require 'spacesuit/recipes/common'
#require 'mongrel_cluster/recipes_2'
#require 'config/recipes/monit'

set :application, "republic"
set :rails_env, "production"
set :ssh_options, {:forward_agent => true}
set :use_sudo, false

default_run_options[:pty] = true
set :scm, "git"
set :branch, "republic"
set :repository,  "git://github.com/red56/the-connected-website.git"
set :keep_releases, 30
set :git_enable_submodules, 1

set :rails_revision, '73fc42cc0b5e94541480032c2941a50edd4080c2' # Fri Sep 19 09:06:35 2008 -0500  -   From master branch


#before "deploy:stop", "republic_services:stop"
#before "deploy:restart", "republic_services:restart" 
#after  "deploy:start",  "republic_services:start"


namespace :deploy do
  task :start do
  end
  task :stop do    
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end