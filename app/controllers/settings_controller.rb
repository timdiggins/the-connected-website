class SettingsController < ApplicationController
  
  before_filter :login_required
  before_filter :set_user
  
  def save_new_avatar
    @user.attributes = params[:user]
    
    return render(:action => :picture) unless @user.avatar && @user.avatar.valid? && @user.save
    
    flash[:notice] = "Saved new avatar."
    redirect_to picture_settings_url
  end

  def update
    return render(:action => :show) unless @user.update_attributes(params[:user])
    
    flash[:notice] = "Saved account settings"
    redirect_to @user
  end
  
  private
    def set_user
      @user = current_user
    end
  
end
