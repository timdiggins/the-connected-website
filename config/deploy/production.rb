require 'spacesuit/recipes/backup'

set :deploy_to, "/var/www/apps/#{application}"
set :domain, "209.20.82.7"

set :user, 'republic'
set :keep_db_backups, 100

role :web, domain
role :app, domain
role :db,  domain, :primary => true

task :install_gem_dependencies do
  run "cd #{current_path} && sudo rake gems:install RAILS_ENV=#{rails_env}"
end

task :link_s3_yml do
  run "ln -nfs #{shared_path}/config/s3.yml #{current_path}/config/s3.yml"
end

task :link_shared_stuff do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/config/cookie_secret #{release_path}/config/cookie_secret"
  run "ln -nfs #{shared_path}/avatars #{release_path}/public/avatars"
  
  run "mkdir -p #{release_path}/tmp/attachment_fu"
  run "mkdir -p #{release_path}/db"
end

after "deploy:symlink", "link_shared_stuff"
after "deploy:symlink", "install_gem_dependencies"
before "deploy:update_code", "deploy:git:pending"
before "deploy:migrate", "backup_to_s3"
before "backup_to_s3", "link_s3_yml"