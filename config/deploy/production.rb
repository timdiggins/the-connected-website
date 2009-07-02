require 'spacesuit/recipes/backup'

set :deploy_to, "/var/www/apps/#{application}"
set :domain, "wminarch.red56.co.uk"

set :user, 'wminarch'
set :keep_db_backups, 100
#this line will go away in the next version of spacesuit
set(:cron_file) { "/etc/cron.daily/#{application}_backup_db_to_s3.sh" }

role :web, domain
role :app, domain
role :db,  domain, :primary => true

task :install_gem_dependencies do
  cmds = []
  cmds << "cd #{current_release}"
  cmds << "rake gems RAILS_ENV=#{rails_env} > /dev/null"
  cmds << "sudo rake gems:install RAILS_ENV=#{rails_env}"
  run cmds.join(' && ')
end

task :link_s3_yml do
  run "ln -nfs #{shared_path}/config/s3.yml #{current_path}/config/s3.yml"
end

task :link_shared_stuff do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/config/cookie_secret #{release_path}/config/cookie_secret"
  run "ln -nfs #{shared_path}/config/flickr.yml #{release_path}/config/flickr.yml"
  run "ln -nfs #{shared_path}/config/amazon_s3.yml #{current_path}/config/amazon_s3.yml"
  
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

task :create_config_files do
  %w(config).each {|e| run "mkdir -p #{shared_path}/#{e}" }

  %w(database.yml amazon_s3.yml s3.yml cookie_secret).each do |e|
    run "touch #{shared_path}/config/#{e}"
  end
end

after "deploy:setup", "create_config_files"
after "deploy:symlink", "link_shared_stuff"
after "deploy:symlink", "install_gem_dependencies"
before "deploy:update_code", "deploy:git:pending"
before "deploy:migrate", "backup_to_s3"
before "backup_to_s3", "link_s3_yml"