

def go
  require File.expand_path(File.dirname(__FILE__) + "/../../config/environment") 

  lines = File.readlines("blog_users.csv")

  lines.each do | line |
    parts = line.split(',')
  
    puts "--------------------------------------------------"
    user = User.new
    user.login = parts[1].strip
    user.name = parts[2].strip
    user.email = parts[3].strip
    user.home_page = parts[4].strip
    user.password = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.login}--") 
                  
    if !user.name.blank? && user.save
      puts "Saved #{user}" 
      puts user.inspect
    else
      puts "***Unable to save #{user}.  #{user.errors.full_messages}"
    end

  end

  
  User.create!(:login => 'Unknown User', :email => "duff@codora.com", :password => Digest::SHA1.hexdigest("--#{Time.now.to_s}--unknown--"))
  
end



if __FILE__ == $0
  go
end