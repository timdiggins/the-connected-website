class HomeController < ApplicationController
  def index
    @featured = Post.featured 
    @featured = Post.sorted_by_updated_at.find(:all, :limit => 6) if @featured.empty?
    @current_featured = @featured.shift
    
    @events = Event.sorted_by_created_at.limit_to(15)
    @users = User.some_having_bio_and_avatar
  end
end
