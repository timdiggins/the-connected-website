class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show, :recent]
  before_filter :find_group, :only => [ :show, :recent, :edit, :update]
  before_filter :find_group_categories, :only => [  :edit, :new]
  #uses_tiny_mce :options => tiny_mce_options, :only => [ :new,:create, :update, :edit ]
  
  RECENT_IMAGES_PER_PAGE = 30
  RECENT_TEXTS_PER_PAGE = 10
  def index
    @groups = Group.order_by_contributed_at
    @group_categories = GroupCategory.all( :include=>:groups)
    if logged_in?
      @your_groups = current_user.groups.all( :include=> :rss_feeds)
    end
  end
  
  def show
    @recent_images = @group.images.unfeatured.limit_to RECENT_IMAGES_PER_PAGE
    @recent_texts = @group.posts.unfeatured.with_no_images.limit_to RECENT_TEXTS_PER_PAGE
    @featured_images = @group.images.featured.limit_to 10 
    @featured_texts = @group.posts.featured.limit_to 5 
  end

  def recent
    @posts = @group.posts(:include=>:images).paginate(:page => params[:page], :per_page => RECENT_TEXTS_PER_PAGE)
  end
  
  def new
    raise PermissionDenied, 'Must be admin to add group' if not logged_in_as_admin?
    
    @group = Group.new(params[:group])
  end
  
  def edit
    raise PermissionDenied if !current_user.can_edit? @group
  end
  
  def update
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
  
  def find_group
    @group = Group.find_by_name!(params[:id])
  end
  def find_group_categories 
      @group_categories = GroupCategory.all
  end
end
