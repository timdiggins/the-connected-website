require 'spacesuit/recipes/backup'

set :deploy_to, "/var/www/apps/#{application}"
set :domain, "next.theconnectedrepublic.org"

set :user, 'republic'
set :keep_db_backups, 100

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :console do
  desc "connect to remote rails console"
  task :default do
    input = ''
    run "cd #{current_path} && ./script/console #{rails_env}" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
end

task :install_gem_dependencies do
  run "cd #{current_path} && 
        rake gems RAILS_ENV=#{rails_env} > /dev/null &&
        sudo rake gems:install RAILS_ENV=#{rails_env}"
end

task :link_s3_yml do
  run "ln -nfs #{shared_path}/config/s3.yml #{current_path}/config/s3.yml"
end

task :link_shared_stuff do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/config/cookie_secret #{release_path}/config/cookie_secret"
  run "ln -nfs #{shared_path}/avatars #{release_path}/public/avatars"
  
  run "mkdir -p #{release_path}/tmp"
  run "mkdir -p #{release_path}/db"
end

namespace :backup do
  desc "List database backups in S3"
  task :list do
    run "cd #{current_path} && rake s3:manage:list RAILS_ENV=#{rails_env}"
  end

  desc "Retrieve a database backup"
  task :retrieve do
    command = "cd #{current_path} && rake s3:retrieve RAILS_ENV=#{rails_env}"
    command << " VERSION=#{ENV['VERSION']}" if ENV['VERSION']
    run command
    
    filename = nil
    run("ls #{current_path}/*.tar.gz") do |channel,identifier,data|
      filename = File.basename(data).chomp
    end
    get "#{current_path}/#{filename}", "tmp/#{filename}"
    run "rm #{current_path}/#{filename}"
  end
end

after "deploy:symlink", "link_shared_stuff"
after "deploy:symlink", "install_gem_dependencies"
before "deploy:update_code", "deploy:git:pending"
before "deploy:migrate", "backup_to_s3"
before "backup_to_s3", "link_s3_yml"