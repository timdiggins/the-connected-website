class CommentsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_comment, :only => [:destroy]
  before_filter :check_owner, :only => [:edit, :update]
  uses_tiny_mce :options => tiny_mce_options, :only => [:create, :edit]
  
  def create
    if ! current_user.may_contribute?
      raise Exception, "#{current_user} not allowed to comment (tried to post)"
    end
    
    @post = Post.find(params[:post_id])
    @comment = Comment.new(params[:comment])
    @comment.post = @post
    @comment.user = current_user
    
    if !@comment.valid?
      flash[:error] = "Comment was empty. You need write something before pressing 'Add comment'" 
      return render(:template => 'posts/show')
    end
    
    Event.create_for(@comment)
    @post.update_attribute(:commented_at, @comment.updated_at)
    current_user.update_attribute(:contributed_at, Time.now)
    @post.subscribers << current_user
    QueuedEmail.create_for(@comment)
    
    flash[:notice] = "Successfully posted comment"
    redirect_to @post
  end
  
  def destroy
    @comment.destroy
    flash[:notice] = "Deleted comment"
    redirect_to @post
  end
  
  def edit
  end

  def update
    @comment.body = params[:comment][:body]
    @comment.save!
    redirect_to @post
  end
  
  protected
  def find_comment
    @post ||= Post.find(params[:post_id])
    @comment ||= @post.comments.find(params[:id])    
  end
  
  def check_owner
    find_comment
    if @comment.user != current_user
      flash[:error] = "Only original comment creator can edit"
      redirect_to @post
      return false
    end
  end
end
