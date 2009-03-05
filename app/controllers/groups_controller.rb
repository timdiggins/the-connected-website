class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show]
  uses_tiny_mce :options => tiny_mce_options, :only => [ :new,:create, :update, :edit ]
  
  def index
    @groups = Group.all
    respond_to do |format|
      format.html { 
        @posts = Post.sorted_by_commented_at.paginate(:page => params[:page], :per_page => 15) 
        @tags = Tag.all_with_count :limit=>40
      }
      format.rss { 
        @posts = Post.sorted_by_commented_at.limit_to(15)
        render :layout => false 
      }
    end
  end
  
  def show
    @group = Group.find_by_name!(params[:id])
    @images = @group.post_images
    @posts = @group.posts.paginate(:page => params[:page], :per_page => 15)
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
