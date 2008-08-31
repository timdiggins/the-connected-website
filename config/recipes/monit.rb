Capistrano::Configuration.instance.load do
  set :monit, "/usr/local/bin/monit"
  set :actions, %w(start stop restart)
  
  namespace :deploy do
    actions.each {|action|
      desc "#{action} mongrels"
      task action.to_sym do
        run "sudo #{monit} #{action} all -g #{application}_mongrels"
      end
    }
    
    namespace :web do
      actions.each {|action|
        desc "#{action} nginx"
        task action.to_sym do
          run "sudo #{monit} #{action} all -g www"
        end
      }      
    end
  end
end