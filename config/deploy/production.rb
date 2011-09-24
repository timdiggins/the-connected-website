#require 'spacesuit/recipes/backup'

set :deploy_via, :remote_cache
set :deploy_to, "/var/www/apps/#{application}_production"
set :domain, "new.theconnectedrepublic.org"

set :user, 'republic'
set :keep_db_backups, 100

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :console do
  desc "connect to remote rails console"
  task :default do
    input = ''
    run "cd #{current_path} && script/console #{rails_env}" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
end

task :install_gem_dependencies do
  run "sh -c 'cd #{current_path} && 
        rake gems RAILS_ENV=#{rails_env} > /dev/null &&
        rake gems:install RAILS_ENV=#{rails_env}'"
end

task :link_s3_yml do
  run "ln -nfs #{shared_path}/config/s3.yml #{current_path}/config/s3.yml"
end

task :link_shared_stuff do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/config/cookie_secret #{release_path}/config/cookie_secret"
  run "ln -nfs #{shared_path}/avatars #{release_path}/public/avatars"
  run "ln -nfs #{shared_path}/config/amazon_s3.yml #{current_path}/config/amazon_s3.yml"
  
  run "mkdir -p #{release_path}/tmp"
  run "mkdir -p #{release_path}/db"
end


after "deploy:symlink", "link_shared_stuff"
after "deploy:symlink", "install_gem_dependencies"
before "deploy:update_code", "deploy:git:pending"
before "deploy:migrate", "link_s3_yml"