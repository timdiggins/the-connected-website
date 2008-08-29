class HomeController < ApplicationController
  def index
    @posts = Post.featured 
    if @posts.size <1 
      @posts = Post.sorted_by_updated_at
    end
    
    @events = Event.sorted_by_created_at
    @users = User.some_having_bio_and_avatar
    @post = @posts[0]
  end
end
