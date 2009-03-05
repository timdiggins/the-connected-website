class SettingsController < ApplicationController  
  before_filter :login_required
  before_filter :set_user
  uses_tiny_mce :options => tiny_mce_options, :only => [ :bio, :update]

  def save_new_avatar
    @user.attributes = params[:user]
    
    return render(:action => :picture) unless @user.avatar && @user.avatar.valid? && @user.save
    
    flash[:notice] = "Saved new avatar."
    redirect_to picture_settings_url
  end
  
  def password
    return if request.get?
    @user.password_required = true
    return unless @user.update_attributes(params[:user])
    
    flash[:notice] = "Saved password"
    redirect_to @user
  end
  
  def username_email
    return if request.get?
    return unless @user.update_attributes(params[:user])
    
    flash[:notice] = "Saved username and email"
    redirect_to @user
  end

  def update
    return render(:action => :username_email) unless @user.update_attributes(params[:user])
    
    flash[:notice] = "Saved account settings"
    redirect_to @user
  end
  
  def show
    redirect_to bio_settings_url
  end
  
  private
    def set_user
      @user = current_user
    end
  
end
