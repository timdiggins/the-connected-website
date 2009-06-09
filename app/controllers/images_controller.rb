class ImagesController < ApplicationController
  before_filter :find_image
  before_filter :current_user_can_edit_image
  
  def destroy
    @image = PostImage.find(params[:id])
    @image.destroy
    flash[:notice] = "Successfully deleted the image."
    redirect_to post_url(@image.post)
  end
  
  def feature
    @image.update_attributes(:featured_at=>Time.now)
    redirect_to post_url(@image.post, :anchor=>'featuring-controls')
  end
  
  def unfeature
    @image.update_attributes(:featured_at=>nil)
    redirect_to post_url(@image.post, :anchor=>'featuring-controls')
  end
  
  protected
  def find_image
    @image = PostImage.find(params[:id])
  end
  
  def current_user_can_edit_image
    current_user_can_edit @image.post
  end
end
