class HomeController < ApplicationController
  def index
    @tags = Tag.all_with_count :limit=>20
    @latestFeature = PostImage.find(:all, :include => :post, :limit=>1,:order => "updated_at DESC")[0]
    @featured = PostImage.find(:all, :include => :post, :limit=>50, :order => "updated_at DESC")
  end
end
