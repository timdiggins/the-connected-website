namespace :web do
  %w(start stop restart).each {|action|
    desc "#{action} webserver"
    task action.to_sym do
      run "sudo #{monit_path} #{action} all -g www"
    end
  }
end
