daemons = %w(rss_feed_fetcher email_notifier)

daemons.each do |daemon|
  namespace daemon.to_sym do
    %w(start stop).each do |action|
      desc "#{action} the #{daemon} daemon"
      task action.to_sym do
        run "sudo #{monit_path} #{action} #{daemon}"
      end
    end
  end
end

namespace :daemons do  
  desc "Start the app daemons"
  task :start do
    daemons.each do |daemons|
      find_and_execute_task("#{daemons}:start")
    end
  end
  
  desc "Stop the app daemons"
  task :stop do
    daemons.each do |daemons|
      find_and_execute_task("#{daemons}:stop")
    end
  end
end

before "deploy:stop",    "daemons:stop"
before "deploy:restart", "daemons:restart"
after  "deploy:start",   "daemons:start"