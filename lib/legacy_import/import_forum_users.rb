# username varchar(25) NOT NULL,
# user_emailtime int(11),
# user_viewemail tinyint(1),
# user_email varchar(255),
# user_website varchar(100),



def go
  require File.expand_path(File.dirname(__FILE__) + "/../../config/environment") 

  lines = File.readlines("forum_users.csv")

  lines.each do | line |
    parts = line.split(',')
  
    puts "--------------------------------------------------"
    user = User.new
    user.login = parts[0].strip
    user.email = parts[1].strip
    user.home_page = parts[2].strip
    user.location = parts[3].strip
    user.password = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.login}--") 
                  
    if user.save
      puts "Saved #{user}" 
      puts user.inspect
    else
      puts "***Unable to save #{user}.  #{user.errors.full_messages}"
    end
    
  end

end



if __FILE__ == $0
  go
end