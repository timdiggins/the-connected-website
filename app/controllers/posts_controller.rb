class PostsController < ApplicationController
  
  before_filter :login_required, :except => [ :index, :show, :featured ]
  before_filter :editor_login_required, :only => [ :feature, :unfeature ]
  uses_tiny_mce :options => tiny_mce_options, :only => [ :new, :show, :create, :update, :edit ]
  
  def index
    respond_to do |format|
      format.html { @posts = Post.sorted_by_updated_at.paginate(:page => params[:page], :per_page => 15) }
      format.rss { 
        @posts = Post.sorted_by_updated_at.limit_to(15)
        render :layout => false 
      }
    end
  end
  
  def new
    @post = Post.new
    @initial_tag = Tag.find_by_id(params[:tag])
  end
  
  def create
    @post = Post.new(params[:post])
    @post.user = current_user
    @initial_tag = Tag.find_by_id(params[:tag])
    return render(:action => :new) unless @post.valid?
    
    Event.create_for(@post)
    current_user.update_attribute(:contributed_at, Time.now)
    @post.tags << @initial_tag if @initial_tag
    @post.subscribers << current_user
    
    redirect_to posts_url
  end
  
  def edit
    @post = Post.find(params[:id])    
  end

  def update
    @post = Post.find(params[:id])
    return render(:action => :edit) unless @post.update_attributes(params[:post])
    
    flash[:notice] = "Successfully updated post"
    
    redirect_to @post
  end
  
  def show
    @post = Post.find(params[:id])    
    @comment = Comment.new
  end
  
  def feature
    @post = Post.find(params[:id])    
    @post.update_attribute(:featured_at, Time.now)
    redirect_to @post
  end
  
  def subscribe
    @post = Post.find(params[:id])    
    @post.subscribers << current_user
    redirect_to @post
  end
  
  def unsubscribe
    @post = Post.find(params[:id])    
    @post.subscribers.delete(current_user)
    redirect_to @post
  end
  
  def unfeature
    @post = Post.find(params[:id])    
    @post.update_attribute(:featured_at, nil)
    redirect_to @post
  end
  
  def featured
    respond_to do |format|
      format.html { @posts = Post.featured.paginate(:page => params[:page], :per_page => 15) }
      format.rss { 
        @posts = Post.featured.limit_to(15)
        render :layout => false 
      }
    end
  end
  
end

