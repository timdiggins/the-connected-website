namespace :rss_feed_fetcher do
  desc "Start the rss_feed_fetcher daemon"
  task :start do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/rss_feed_fetcher_daemon start"
  end
  
  desc "Stop the rss_feed_fetcher daemon"
  task :stop do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/rss_feed_fetcher_daemon stop"
  end
end
