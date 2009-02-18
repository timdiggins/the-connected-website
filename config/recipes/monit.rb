Capistrano::Configuration.instance.load do
  set :monit_path, "/usr/local/bin/monit"
  namespace :web do
    %w(start stop restart).each {|action|
      desc "#{action} webserver"
      task action.to_sym do
        run "sudo #{monit_path} #{action} all -g www"
      end
    }
  end

  namespace :monit do
    desc "Display monit's status"
    task :status do
      puts capture("sudo #{monit_path} status")
    end
  end
end