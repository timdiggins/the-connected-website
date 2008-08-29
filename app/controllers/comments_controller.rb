class CommentsController < ApplicationController
  
  before_filter :login_required

  def create
    @post = Post.find(params[:post_id])
    @comment = Comment.new(params[:comment])
    @comment.post = @post
    @comment.user = current_user
    
    return render(:template => 'posts/show') unless @comment.valid?
    
    Event.create_for(@comment)
    @post.updated_at = @comment.updated_at
    @post.save
    
    
    flash[:notice] = "Successfully posted comment"
    redirect_to @post
  end
  
end
