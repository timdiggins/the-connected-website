class UsersController < ApplicationController
  
  before_filter :admin_login_required, :only => [ :become, :destroy, :trust ]
  
  def new
    @user = User.new(params[:user])
    store_location(params[:return_to]) if params[:return_to]
  end
  
  def create
    @user = User.new(params[:user])
    
    return render(:action => :new) unless @user.save
    
    self.current_user = @user
    
    redirect_back_or_default(root_url)
    flash[:notice] = "Thanks for signing up!  You have been logged in."
  end
  
  def show
    @user = User.find_by_login!(params[:id])
    @hide_user_in_events = true
  end
  
  def destroy
    @user = User.find_by_login!(params[:id])
    @user.destroy_creations
    @user.destroy
    flash[:notice] = "Successfully deleted the user."
    redirect_to users_url
  end

  def index
    @users = User.has_bio_and_avatar.recently_contributed(10)
    @recently_signed_up = User.recently_signed_up
  end
  
  def all
    @users = User.order_by_created_at.paginate(:page => params[:page], :per_page => 15)
  end
  
  def become
    @user = User.find_by_login(params[:id])
    if session[:original_admin_user].nil?
      session[:original_admin_user] = current_user.login
    end
    self.current_user = @user
    session[:as_someone_else] = true
    redirect_to root_url
  end

  def unbecome
    if current_user.login != params[:id]
      raise Exception, "Can't unbecome - wasn't right user: expected #{current_user.login}, got #{params[:id]}"
    end
    original_admin = session[:original_admin_user]
    if !session[:as_someone_else] or original_admin.nil?
      raise Exception, "Can't unbecome - you weren't unbecoming"
    end
    @user = User.find_by_login(original_admin)
    self.current_user = @user
    session[:as_someone_else] = nil
    session[:original_admin_user] = nil
    flash[:notice] = "Successfully became #{current_user} again"
    redirect_to root_url
  end
  
  def trust
    @user = User.find_by_login(params[:id])
    @user.update_attributes(:is_new=>false)
    redirect_to user_url(@user)
  end
  
end
