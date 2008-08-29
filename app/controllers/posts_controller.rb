class PostsController < ApplicationController
  
  before_filter :login_required, :except => [ :index, :show ]
  
  def index
    @posts = Post.sorted_by_updated_at
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(params[:post])
    @post.user = current_user
    return render(:action => :new) unless @post.valid?
    
    Event.create_for(@post)
    
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
  
end
