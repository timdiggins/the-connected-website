class SettingsController < ApplicationController
  
  before_filter :login_required
  
  def save_new_avatar
    @user = current_user
    @user.attributes = params[:user]
    
    return render(:action => :picture) unless @user.avatar && @user.avatar.valid? && @user.save
    
    flash[:notice] = "Saved new avatar."
    redirect_to picture_settings_url
  end

  def update
    @user = User.find(current_user.id)
    return render(:action => :show) unless @user.update_attributes(params[:user])
    
    flash[:notice] = "Saved account settings"
    redirect_to @user
  end
  
  def username_email
    @user = current_user
  end
  
  def bio
    @user = current_user
  end
  
  def picture
    @user = current_user
  end
  
  
end
