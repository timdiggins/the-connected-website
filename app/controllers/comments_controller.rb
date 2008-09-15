class CommentsController < ApplicationController
  
  before_filter :login_required
  uses_tiny_mce :options => tiny_mce_options, :only => [:create]

  def create
    @post = Post.find(params[:post_id])
    @comment = Comment.new(params[:comment])
    @comment.post = @post
    @comment.user = current_user
    
    return render(:template => 'posts/show') unless @comment.valid?
    
    Event.create_for(@comment)
    @post.update_attribute(:updated_at, @comment.updated_at)
    
    flash[:notice] = "Successfully posted comment"
    redirect_to @post
  end
  
  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    
    @comment.destroy
    flash[:notice] = "Deleted comment"
    redirect_to @post
  end
  
end
