# = S3 Rake - Use S3 as a backup repository for your SVN repository, code directory, and MySQL database
#
# Author::    Adam Greene
# Copyright:: (c) 2006 6 Bar 8, LLC., Sweetspot.dm
# License::   GNU
#
# Feedback appreciated: adam at [nospam] 6bar8 dt com
#
# = Synopsis
#
#  from the CommandLine within your RubyOnRails application folder
#  $ rake -T
#    rake s3:backup                      # Backup database to S3
#    rake s3:manage:clean_up             # Remove all but the last 10 most recent backup archive or
#                                        # optionally specify KEEP=5 to keep the last 5
#    rake s3:manage:delete_bucket        # delete bucket.  You need to pass in NAME=bucket_to_delete.
#                                        # Set FORCE=true if you want to delete the bucket even if
#                                        # there are items in it.
#    rake s3:manage:list                 # list all your backup archives
#    rake s3:manage:list_buckets         # list all your S3 buckets
#    rake s3:retrieve                    # retrieve the latest revision of the database from S3, or
#                                        # optionally specify a VERSION=this_archive.tar.gz
#
# = Description
#
#    * You will need a 's3.yml' file in ./config/.  Sure, you can hard-code the information in this
#      rake task, but I like the idea of keeping all your configuration information in one place.
#      The File will need to look like:
#        connection:
#          aws_access_key: '<YOUR ACCESS KEY HERE>'
#          aws_secret_access_key: '<YOUR _SECRET_ ACCESS KEY HERE>'
#          use_ssl: true
#        project_name: my_project_name   # optional, inferred if not specified
#
#  Once these two requirements are met, you can easily integrate these rake tasks into capistrano
#  tasks or into cron.
#    * For cron, put this into a file like <your.app.name>.backup.cron.  You can drop this file into
#      /etc/cron.daily, and make sure you chmod +x <your.app.name>.backup.cron.  Also make sure it
#      is owned by the appropriate user (probably 'root'.):
#
#        #!/bin/sh
#
#        # change the paths as you need...
#        cd /var/www/apps/<your.app>/current/ && rake s3:backup >/dev/null 2>&1
#
#    * within your capistrano recipe file, you can tasks like these:
#
#        task :before_update_code, :roles => [:app, :db, :web] do
#          run "cd #{current_path} && rake --trace RAILS_ENV=production s3:backup"
#        end

# = Credits and License
#
#  inspired by rshll, developed by Dominic Da Silva:
#    http://rubyforge.org/projects/rsh3ll/
#
# This library is licensed under the GNU General Public License (GPL)
#  [http://dev.perl.org/licenses/gpl1.html].

require 'yaml'
require 'active_support'

namespace :s3 do
  
  task :establish_connection do
    require 'aws/s3'
    
    keys = nil
    begin
      keys = S3Backup.config['connection'].symbolize_keys
    rescue
      raise "Could not load AWS keys from: #{RAILS_ROOT}/config/s3.yml"
    end
    
    AWS::S3::Base.establish_connection!(keys)
  end
  
  desc "Backup the database to S3"
  task :backup => "s3:establish_connection" do
    S3Backup.backup
  end

  desc "retrieve the latest revision of the database from S3, or optionally specify a VERSION=this_archive.tar.gz"
  task :retrieve => "s3:establish_connection" do
    S3Backup.retrieve_file 'db', ENV['VERSION']
  end

  namespace :manage do
    desc "Remove all but the last 10 most recent backup archive or optionally specify KEEP=5 to keep the last 5"
    task :clean_up => "s3:establish_connection" do
      keep_num = ENV['KEEP'] ? ENV['KEEP'].to_i : 10
      puts "keeping the last #{keep_num}"
      S3Backup.cleanup_bucket('db', keep_num)
    end

    desc "list all your backup archives"
    task :list => "s3:establish_connection" do
      S3Backup.print_bucket 'db'
    end

    desc "list all your S3 buckets"
    task :list_buckets => "s3:establish_connection" do
      puts AWS::S3::Service.buckets.map { |bucket| bucket.name }
    end
    
    desc "delete bucket.  You need to pass in NAME=bucket_to_delete.  Set FORCE=true if you want to delete the bucket even if there are items in it."
    task :delete_bucket => "s3:establish_connection" do
      name = ENV['NAME']
      raise "Specify a NAME=bucket that you want deleted" if name.blank?
      force = ENV['FORCE'] == 'true' ? true : false

      AWS::S3::Bucket.delete(name, :force => force)
      puts "deleted bucket #{S3Backup.bucket_name(name)}."
    end
  end
end

module S3Backup
  module_function
  
  def config
    @config ||= YAML::load_file("#{RAILS_ROOT}/config/s3.yml")
  end

  def backup
    msg "backing up the DATABASE to S3"
    make_bucket('db')
    archive = "/tmp/#{archive_name('db')}"

    msg "retrieving db info"
    database, user, password = retrieve_db_info

    msg "dumping db"
    cmd = "mysqldump --opt --skip-add-locks -u#{user} "
    puts cmd + "... [password filtered]"
    cmd += " -p'#{password}' " unless password.nil?
    cmd += " #{database} > #{archive}"
    result = system(cmd)
    raise("mysqldump failed.  msg: #{$?}") unless result

    send_to_s3('db', archive)
  end

  def msg(text)
    puts " -- msg: #{text}"
  end

  # will save the file from S3 in the pwd.
  def retrieve_file(name, specific_file)
    msg "retrieving a #{name} backup from S3"
    objects = AWS::S3::Bucket.find(bucket_name(name)).objects
    raise "No #{name} backups to retrieve" if objects.size < 1
  
    o = objects.find{|o| o.key == specific_file}
    raise "Could not find the file '#{specific_key}' in the #{name} bucket" if o.nil? && !specific_file.nil?
    key = specific_file.nil? ? objects.last.key : o.key
    msg "retrieving archive: #{key}"
    File.open(key, "wb") { |f| f.write(AWS::S3::S3Object.value(key, bucket_name(name))) }  
    msg "retrieved file './#{key}'"
  end

  # print information about an item in a particular bucket
  def print_bucket(name)
    msg "#{bucket_name(name)} Bucket"
    AWS::S3::Bucket.find(bucket_name(name)).objects.each do |o| 
      puts "size: #{o.size/1.kilobyte}KB,  Name: #{o.key},  Last Modified: #{o.last_modified.to_s(:short)} UTC"
    end
  rescue AWS::S3::NoSuchBucket
  end

  # go through and keep a certain number of items within a particular bucket, 
  # and remove everything else.
  def cleanup_bucket(name, keep_num, convert_name=true)
    msg "cleaning up the #{name} bucket"
    bucket = convert_name ? bucket_name(name) : name
    objects = AWS::S3::Bucket.find(bucket).objects #will only retrieve the last 1000
    remove = objects.size-keep_num-1
    objects[0..remove].each do |o|
      AWS::S3::S3Object.delete(o.key, bucket)
      puts "deleted #{bucket}/#{o.key}, #{o.last_modified.to_s(:short)} UTC."
    end unless remove < 0
  rescue AWS::S3::NoSuchBucket
  end

  # programatically figure out what to call the backup bucket and 
  # the archive files.  Is there another way to do this?
  def project_name
    return config['project_name'] if config['project_name']
    # using Dir.pwd will return something like: 
    #   /var/www/apps/staging.sweetspot.dm/releases/20061006155448
    # instead of
    # /var/www/apps/staging.sweetspot.dm/current
    pwd = ENV['PWD'] || Dir.pwd
    #another hack..ugh.  If using standard capistrano setup, pwd will be the 'current' symlink.
    pwd = File.dirname(pwd) if File.symlink?(pwd)
    File.basename(pwd)
  end

  # create S3 bucket.  If it already exists, not a problem!
  def make_bucket(name)
    msg "making bucket #{bucket_name(name)}"
    AWS::S3::Bucket.create(bucket_name(name))
  end

  def bucket_name(name)
    # it would be 'nicer' if could use '/' instead of '_' for bucket names...but for some reason S3 doesn't like that
    "#{token(name)}_backup"
  end

  def token(name)
    "#{project_name}_#{name}"
  end

  def archive_name(name)
    @timestamp ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
    token(name).sub('_', '.') + ".#{RAILS_ENV}.#{@timestamp}"
  end

  # put files in a zipped tar everything that goes to s3
  # send it to the appropriate backup bucket
  # then does a cleanup
  def send_to_s3(name, tmp_file)
    archive = "/tmp/#{archive_name(name)}.tar.gz"

    msg "archiving #{name}"
    cmd = "tar -cpzf #{archive} #{tmp_file}"
    puts cmd
    system cmd

    msg "sending archived #{name} to S3"
    AWS::S3::S3Object.store(File.basename(archive), open(archive), bucket_name(name), :access => :private)
    msg "finished sending #{name} S3"

    msg "cleaning up"
    cmd = "rm -rf #{archive} #{tmp_file}"
    puts cmd
    system cmd  
  end

  def retrieve_db_info
    config_file = YAML::load_file("#{RAILS_ROOT}/config/database.yml")
    return [
      config_file[RAILS_ENV]['database'],
      config_file[RAILS_ENV]['username'],
      config_file[RAILS_ENV]['password']
    ]
  end
end