class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end
  
  def show
    @group = Group.find_by_name!(params[:id])
  end
  
  def new
    raise PermissionDenied, 'Must be admin to add group' if not logged_in_as_admin?
    
    @group = Group.new(params[:group])
  end
  
  def create
    raise PermissionDenied, 'Must be admin to add group' if not logged_in_as_admin?

    @group = Group.new(params[:group])
    
    return render(:action => :new) unless @group.save
    
    redirect_to @group
    flash[:notice] = "Group #{@group} created."
  end
  
  
end
