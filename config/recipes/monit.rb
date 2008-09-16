Capistrano::Configuration.instance.load do
  set :monit, "/usr/local/bin/monit"
  
  namespace :deploy do
    desc "restart mongrels"
    task :restart do
      run "sudo #{monit} unmonitor all -g #{application}_mongrels"
      run "sudo /usr/bin/mongrel_rails cluster::stop -C /etc/mongrel_cluster/#{application}.yml --clean"
      run "sudo /usr/bin/mongrel_rails cluster::start -C /etc/mongrel_cluster/#{application}.yml --clean"
      run "sudo #{monit} monitor all -g #{application}_mongrels"
    end
    
    desc "stop mongrels"
    task :stop do
      run "sudo #{monit} unmonitor all -g #{application}_mongrels"
      run "sudo /usr/bin/mongrel_rails cluster::stop -C /etc/mongrel_cluster/#{application}.yml --clean"
    end
    
    desc "start mongrels"
    task :start do
      run "sudo /usr/bin/mongrel_rails cluster::start -C /etc/mongrel_cluster/#{application}.yml --clean"
      run "sudo #{monit} monitor all -g #{application}_mongrels"
    end    
    
    namespace :web do
      %w(start stop restart).each {|action|
        desc "#{action} nginx"
        task action.to_sym do
          run "sudo #{monit} #{action} all -g www"
        end
      }      
    end
  end
end