namespace :email_notifier do
  desc "Start the email_notifier daemon"
  task :start do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/email_notifier start"
  end
  
  desc "Stop the email_notifier daemon"
  task :stop do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/email_notifier stop"
  end
end
