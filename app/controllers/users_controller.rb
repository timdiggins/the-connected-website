class UsersController < ApplicationController
  
  before_filter :admin_login_required, :only => [ :become ]
  
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
  
  def index
    @users = User.has_bio_and_avatar.recently_contributed(10)
    @recently_signed_up = User.recently_signed_up
  end
  
  def all
    @users = User.order_by_created_at.paginate(:page => params[:page], :per_page => 15)
  end
  
  def become
    @user = User.find_by_login(params[:id])
    self.current_user = @user
    session[:as_someone_else] = true
    redirect_to root_url
  end

end
