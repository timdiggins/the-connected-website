# require 'spacesuit/recipes/backup'

set :deploy_to, "/var/www/apps/#{application}"
set :domain, "209.20.82.7"

set :user, 'republic'

role :web, domain
role :app, domain
role :db,  domain, :primary => true

task :install_gem_dependencies do
  run "cd #{current_path} && rake gems:install RAILS_ENV=#{rails_env}"
end

task :post_deploy do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/config/cookie_secret #{release_path}/config/cookie_secret"
  
  run "mkdir -p #{release_path}/tmp"
  run "mkdir -p #{release_path}/db"
end

after "deploy:symlink", "post_deploy"
before "deploy:update_code", "deploy:git:pending"
after "deploy:update", "install_gem_dependencies"