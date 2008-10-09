class HomeController < ApplicationController
  def index
    @featured = Post.featured.limit_to(6) 
    @featured = Post.sorted_by_updated_at.limit_to(6) if @featured.empty?
    @current_featured = @featured.shift
    
    @events = Event.sorted_by_created_at.limit_to(15)
    @users = User.recently_contributed(3)
  end
end
