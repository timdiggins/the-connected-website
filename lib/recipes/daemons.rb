daemons = %w(rss_feed_fetcher email_notifier)

daemons.each do |daemon|
  namespace daemon.to_sym do
    %w(start stop restart).each do |action|
      desc "#{action} the #{daemon} daemon"
      task action.to_sym do
        run "sudo #{monit_path} #{action} #{daemon}"
      end
    end
  end
end

namespace :daemons do
  %w(start stop restart).each do |action|
    desc "#{action} the app daemons"
    task action.to_sym do
      daemons.each do |daemons|
        find_and_execute_task("#{daemons}:#{action}")
      end
    end
  end

  # desc "restart the app daemons"
  # task :restart do
  #   daemons.each do |daemons|
  #     find_and_execute_task("#{daemons}:stop")
  #     find_and_execute_task("#{daemons}:start")
  #   end
  # end
end

before "deploy:stop",    "daemons:stop"
before "deploy:restart", "daemons:restart"
after  "deploy:start",   "daemons:start"