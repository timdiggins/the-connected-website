class TopicsController < ApplicationController
  
  before_filter :login_required, :only => [ :create, :destroy ]
  
  def show
    @topic = Topic.find(params[:id])
  end
  
  def create
    @post = Post.find(params[:post_id])
    @topic = Topic.find_by_name(params[:topic_name]) || Topic.new(:name => params[:topic_name])
    @post.topics << @topic
    redirect_to @post
  end
  
  def destroy
    @post = Post.find(params[:post_id])
    @topic = Topic.find(params[:id])
    @post.topics.delete(@topic)
    redirect_to @post
  end
  
  def index
    @topics = Topic.has_posts
  end
  
    def edit
    @topic = Topic.find(params[:id])    
  end

  def update
    @topic = Topic.find(params[:id])
    return render(:action => :edit) unless @topic.update_attributes(params[:topic])
    
    flash[:notice] = "Successfully updated topic"
    
    redirect_to @topic
  end

  
end
