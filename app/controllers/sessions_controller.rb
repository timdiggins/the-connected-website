class SessionsController < ApplicationController

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      handle_remember_me
      
      redirect_back_or_default(root_url)
      flash[:notice] = "Logged in successfully"
    else
      flash.now[:error]= "Invalid login or password."
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to(login_url)
  end
  
  def forgot_password
    @email = params[:email]
    
    return if request.get? || @email.blank?
    user = User.find_by_email(@email)
    if !user
      flash[:error] = "Unable to find a user with that email address."
    else
      user.make_reset_password_token
      Mailer.deliver_forgot_password(user, reset_password_url(:reset_password_token => user.reset_password_token))
      
      flash[:notice] = "An email to help you login has been sent to #{user.email}."
      redirect_to login_url
    end
  end
  
  def reset_password
    @user = User.find_by_reset_password_token(params[:reset_password_token])
    unless @user
      flash[:error] = "Unable to reset your password.  Perhaps the link you clicked has already been used."
      return redirect_to(forgot_password_url)
    end
    
    return unless request.post?
    @user.password_required = true
    if @user.update_attributes(params[:user])
      @user.update_attribute(:reset_password_token, nil)
      flash[:notice] = "Your password has been changed and you've been logged in."
      self.current_user = @user
      redirect_to projects_url
    end
  end
  
  def new
    store_location(params[:return_to]) if params[:return_to]
  end
  
  private
    def handle_remember_me
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
    end
        
end
