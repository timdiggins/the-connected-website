require File.expand_path(File.dirname(__FILE__) + "/../../config/environment") 

lines = File.readlines("blog_users.csv")

lines.each do | line |
  parts = line.split(',')
  
  puts "--------------------------------------------------"
  user = User.new
  user.login = parts[1]
  user.name = parts[2]
  user.email = parts[3]
  user.home_page = parts[4]
  user.password = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.login}--") 
                  
  unless user.name.blank?
    puts "Saved #{user}" if user.save
  end

end

User.create!(:login => 'unknown', :email => "duff@codora.com", :password => Digest::SHA1.hexdigest("--#{Time.now.to_s}--unknown--"))