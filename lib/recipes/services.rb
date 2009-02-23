namespace :services do  
  services = %w(email_notifier rss_feed_fetcher)

  desc "Start the app services"
  task :start do
    services.each do |service|
      find_and_execute_task("#{service}:start")
    end
  end
  
  desc "Stop the app services"
  task :stop do
    services.each do |service|
      find_and_execute_task("#{service}:stop")
    end
  end
  
  desc "Restart the app services"
  task :restart do
    find_and_execute_task("services:stop")
    find_and_execute_task("services:start")
  end
end