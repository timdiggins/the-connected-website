class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show]
  before_filter :find_group_categories, :only => [ :index, :edit, :new]
  #uses_tiny_mce :options => tiny_mce_options, :only => [ :new,:create, :update, :edit ]
  
  def index
    @groups = Group.order_by_contributed_at
  end
  
  def show
    @group = Group.find_by_name!(params[:id])
    @recent_images = @group.images.limit_to 20
    @posts = @group.posts.paginate(:page => params[:page], :per_page => 15)
    @featured_images = @group.images.featured.limit_to 10 
    @featured_texts = @group.posts.featured.limit_to 10 
  end
  
  def new
    raise PermissionDenied, 'Must be admin to add group' if not logged_in_as_admin?
    
    @group = Group.new(params[:group])
  end
  
  def edit
    @group = Group.find_by_name!(params[:id])    
    raise PermissionDenied if !current_user.can_edit? @group
  end
  
  def update
    @group = Group.find_by_name!(params[:id])
    raise PermissionDenied if !current_user.can_edit? @group
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
  
  def find_group_categories 
      @group_categories = GroupCategory.all
  end
end
