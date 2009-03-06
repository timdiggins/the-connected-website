class ImageController < ApplicationController
  def destroy
    @image = PostImage.find(params[:id])
    @image.destroy
    flash[:notice] = "Successfully deleted the image."
    redirect_to post_url(@image.post)
  end
end
