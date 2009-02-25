set :monit_path, "/usr/local/bin/monit"
namespace :monit do
  %w(summary status).each do |action|
    desc "run monit #{action}"
    task action.to_sym  do
      puts capture("sudo #{monit_path} #{action}")
    end
  end
end
