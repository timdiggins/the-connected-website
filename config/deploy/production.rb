# require 'spacesuit/recipes/backup'

set :deploy_to, "/var/www/apps/#{application}"
set :domain, "209.20.82.7"

set :user, 'republic'

role :web, domain
role :app, domain
role :db,  domain, :primary => true


task :post_deploy do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "mkdir -p #{release_path}/tmp"
  run "mkdir -p #{release_path}/db"
end

after "deploy:symlink", "post_deploy"
