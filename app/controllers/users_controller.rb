class UsersController < ApplicationController
  
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
    @user = User.find_by_login(params[:id])
  end
  
  def index
    @users = User.all
  end
  

end
