Capistrano::Configuration.instance.load do
  set :monit, "/usr/local/bin/monit"
  
  namespace :deploy do
    desc "restart mongrels"
    task :restart do
      stop
      start
    end
    
    desc "stop mongrels"
    task :stop do
      run "sudo #{monit} unmonitor all -g #{application}_mongrels"
      sleep 0.5
      mongrel.stop
    end
    
    desc "start mongrels"
    task :start do
      mongrel.start
      run "sudo #{monit} monitor all -g #{application}_mongrels"
    end        
  end
  
  namespace :web do
    %w(start stop restart).each {|action|
      desc "#{action} webserver"
      task action.to_sym do
        run "sudo #{monit} #{action} all -g www"
      end
    }      
  end
  
  namespace :mongrel do
    %w(start stop restart).each {|action|
      desc "#{action} mongrels"
      task action.to_sym do
        run "sudo /usr/bin/mongrel_rails cluster::#{action} -C /etc/mongrel_cluster/#{application}.yml --clean"
      end
    }    
  end
  
end