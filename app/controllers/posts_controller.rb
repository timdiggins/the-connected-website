class PostsController < ApplicationController
  
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :editor_login_required, :only => [ :feature, :unfeature ]
  uses_tiny_mce :options => tiny_mce_options, :only => [:new, :show, :create, :update]
  
  def index
    @posts = Post.sorted_by_updated_at.paginate(:page => params[:page], :per_page => 15)
  end
  
  def new
    @post = Post.new
    @initial_topic = Topic.find_by_id(params[:topic])
  end
  
  def create
    @post = Post.new(params[:post])
    @post.user = current_user
    @initial_topic = Topic.find_by_id(params[:topic])
    return render(:action => :new) unless @post.valid?
    
    Event.create_for(@post)
    @post.topics << @initial_topic if @initial_topic
    
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
  
  def unfeature
    @post = Post.find(params[:id])    
    @post.update_attribute(:featured_at, nil)
    redirect_to @post
  end
  
end
