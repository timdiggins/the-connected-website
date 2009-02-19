class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show]
  
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
  
  def edit
    @group = Group.find_by_name!(params[:id])    
    raise PermissionDenied if !current_user.can_moderate? @group
  end
  
  def update
    @group = Group.find_by_name!(params[:id])
    raise PermissionDenied if !current_user.can_moderate? @group
    @group.attributes = params[:group]
    return render(:action => :edit) unless @group.save
    redirect_to @group
  end
  
  def create
    raise PermissionDenied, 'Must be admin to add group' if not logged_in_as_admin?
    
    @group = Group.new(params[:group])
    return render(:action => :new) unless @group.save
    
    redirect_to @group
    flash[:notice] = "Group #{@group} created."
  end
  
  
end
