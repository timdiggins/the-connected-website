namespace :log do
  desc "tail rails #{rails_env} log file"
  task "tail_#{rails_env}".to_sym, :roles => :app do
    tail "#{shared_path}/log/#{rails_env}.log"
  end

  %w(error access rewrite).each{|type|
    desc "tail apache #{type} log"
    task "tail_apache_#{type}".to_sym, :roles => :web do
      tail "/var/log/apache2/#{application}_#{type}.log", :sudo
    end
  }

  def tail(file, via=:run)
    # how to exit cleanly so that we don't get a stack trace?
    invoke_command("tail -f #{file}", {:via => via}) do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err
    end
  end
end

namespace :console do
  desc "connect to remote rails console"
  task :default do
    input = ''
    run "cd #{current_path} && script/console #{rails_env}" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
end
