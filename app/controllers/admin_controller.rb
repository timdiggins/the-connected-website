class AdminController < ApplicationController
  before_filter :admin_login_required
  
  def emails
    @users = User.all
  end
  
  def stats
    
  end
  
end
