module UsersHelper
  
  def link_to_user(user)
    return nil unless user
    link_to h(user), user
  end
  
end
