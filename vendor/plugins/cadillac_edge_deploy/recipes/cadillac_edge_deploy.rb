namespace :deploy do 
  task :cadillac_edge do
    run <<-CMD
      cd #{latest_release} &&
      /usr/bin/env ruby vendor/plugins/cadillac_edge_deploy/lib/cadillac_edge_deploy.rb #{rails_revision} #{latest_release}
    CMD
  end
end

after  "deploy:update_code", "deploy:cadillac_edge"
