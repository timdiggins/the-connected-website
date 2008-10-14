module UsersHelper
  
  def link_to_user(user)
    return nil unless user
    link_to h(user), user
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
