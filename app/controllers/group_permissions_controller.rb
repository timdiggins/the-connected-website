class GroupPermissionsController < ApplicationController
  def create
    user = User.find_by_login params[:user_id]
    group = Group.find_by_name params[:id]
    gp = GroupPermission.new :group=>group, :user=>user
    gp.save!
    flash[:notice] = "Added as moderator"
    redirect_to user_group_permissions_url(user)
  end
  
  def destroy
    user = User.find_by_login params[:user_id]
    group = Group.find_by_name params[:id]
    begin
      gp = GroupPermission.find_by_group_and_user(:group=>group,:user=>user)
      flash[:notice] = "Removed as moderator"
    rescue
      flash[:error] = "Couldn't remove - try again?"
    end
    gp.destroy
    redirect_to user_group_permissions_url(user)
  end
  
  def index
    raise PermissionDenied unless logged_in_as_admin? 
    @user = User.find_by_login(params[:user_id])
    @groups_permitted = @user.group_permissions.collect {|gp| gp.group }
    @groups = Group.all
  end
  
end
