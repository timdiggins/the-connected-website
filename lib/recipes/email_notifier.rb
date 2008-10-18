
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

namespace :republic_services do
  desc "Start the republic services"
  task :start do
    find_and_execute_task("email_notifier:start")
  end
  
  desc "Stop the republic services"
  task :stop do
    find_and_execute_task("email_notifier:stop")
  end
  
  desc "Restart the republic services"
  task :restart do
    find_and_execute_task("republic_services:stop")
    find_and_execute_task("republic_services:start")
  end
end

