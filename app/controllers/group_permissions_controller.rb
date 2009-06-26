class GroupPermissionsController < ApplicationController
  before_filter :login_required
  
  def create
    @user = User.find_by_login params[:user_id]
    group = Group.find_by_name params[:id]
    gp = GroupPermission.new :group=>group, :user=>@user
    gp.save!
    flash[:notice] = "Added as moderator"
    do_redirect 
  end
  
  def destroy
    @user = User.find_by_login params[:user_id]
    group = Group.find_by_name params[:id]
    begin
      gp = GroupPermission.find_by_group_and_user(:group=>group,:user=>@user)
      flash[:notice] = "Removed as moderator"
    rescue
      flash[:error] = "Couldn't remove - try again?"
    end
    gp.destroy
    do_redirect 
  end
  
  def do_redirect
    if params[:return_to]
      redirect_to params[:return_to]
    else
      redirect_to user_group_permissions_url(@user)
    end
  end
  
  def index
    raise PermissionDenied unless logged_in_as_admin? 
    @user = User.find_by_login(params[:user_id])
    @groups_permitted = @user.groups
    @groups = Group.all
  end
  
end
