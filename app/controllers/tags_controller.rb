class TagsController < ApplicationController
  
  before_filter :login_required, :only => [ :create, :destroy, :edit, :update ]
  
  def show
    @tag = Tag.find_by_name!(params[:id])
  end
  
  def create
    @post = Post.find(params[:post_id])
    @tag = Tag.find_by_name(params[:tag_name]) || Tag.new(:name => params[:tag_name])
    @post.tags << @tag
    
    Event.create_for(PostAddedToTagEvent.new(:user => current_user, :tag => @tag, :post => @post))
    redirect_to @post
  end
  
  def destroy
    @post = Post.find(params[:post_id])
    @tag = Tag.find_by_name!(params[:id])
    @post.tags.delete(@tag)

    Event.create_for(PostRemovedFromTagEvent.new(:user => current_user, :tag => @tag, :post => @post))
        
    redirect_to @post
  end
  
  def index
    @tags = Tag.all_with_count :limit=>100
  end
  
  def edit
    @tag = Tag.find_by_name!(params[:id])    
  end

  def update
    @tag = Tag.find_by_name!(params[:id])
    return render(:action => :edit) unless @tag.update_attributes(params[:tag])
    
    flash[:notice] = "Successfully updated tag"
    
    redirect_to @tag
  end
  
end
