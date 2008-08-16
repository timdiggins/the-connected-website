module AvatarsHelper

  def avatar_for(user, size = :medium) 
    image_tag(avatar_filename(user, size), :class => "profile_avatar")
  end
  
  def link_to_avatar_for(user, size = :medium) 
    link_to(avatar_for(user, size), user)
  end
  
  def avatar_filename(user, size = :medium) 
    if user.avatar
      user.avatar.public_filename(size)
    else 
      "default_avatar_#{size}.png"
    end 
  end
  
  def hide_avatar_form
    !@user.avatar || (@user.avatar && @user.avatar.valid?)
  end
  
end