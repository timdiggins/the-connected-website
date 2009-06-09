class HomeController < ApplicationController
  def index
    @tags = Tag.all_with_count :limit=>20

    featured_images = PostImage.featured.limit_to(13)
    if (featured_images.size==0)
      featured_images = PostImage.find(:all, :include => :post, :limit=>13,:order => "updated_at DESC")
    end    
    @latestFeaturedImage = featured_images[0]
    @otherFeaturedImages = featured_images[1..-1]
    
    featured_posts = Post.featured.limit_to(13)
    if (featured_posts.size==0)
      featured_posts = Post.find(:all, :limit=>13,:order => "updated_at DESC")
    end    
    @latestFeaturedPost = featured_posts[0]
    @otherFeaturedPosts = featured_posts[1..-1]
    

  end
end
