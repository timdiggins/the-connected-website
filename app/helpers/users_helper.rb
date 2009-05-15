module UsersHelper
  
  def link_to_user(user)
    return nil unless user
    userrep = h(user) 
    if user.is_new
      userrep = "#{userrep} <span class='newuserflag'>(New User)</span>"
    end
    link_to userrep, user
  end
  
  def user_home_page(user)
    if @user.home_page.starts_with?("http://") || @user.home_page.starts_with?("https://") 
      address = @user.home_page
    else
      address = "http://#{@user.home_page}"
    end
    
    link_to @user.home_page, address, :rel => :me
  end
  
  
end
