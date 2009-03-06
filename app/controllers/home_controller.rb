class HomeController < ApplicationController
  def index

    @tags = Tag.all_with_count :limit=>20
    @latestFeature = PostImage.find(:all, :include => :post, :limit=>1)
    @featured = PostImage.find(:all, :include => :post, :limit=>50)
  end
end
