#adapted from https://github.com/ntalbott/spacesuit/blob/master/lib/spacesuit/recipes/backup.rb

set :keep_db_backups, 20
set(:backup_command) { "cd #{current_path} && rake RAILS_ENV=#{rails_env} KEEP=#{keep_db_backups} s3:backup s3:manage:clean_up" }
set(:cron_file) { "/etc/cron.daily/#{client}_#{application}_backup_db_to_s3.sh" }

namespace :backup_to_s3 do

  desc "Backup database to s3"
  task :backup do
    run backup_command
  end

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

  desc "Install a cron task that runs the backup daily"
  task :setup_cron do
    sudo_put %(#!/bin/sh

#{backup_command} >/dev/null 2>&1), cron_file

    sudo "chown root:root #{cron_file}"
    sudo "chmod 755 #{cron_file}"
  end

end

# after "deploy:setup", "backup_to_s3:setup_cron"
before "deploy:migrate", "backup_to_s3:backup"
before "backup_to_s3:backup", "link_s3_yml"
