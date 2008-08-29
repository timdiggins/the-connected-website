class HomeController < ApplicationController
  def index
    @posts = Post.sorted_by_updated_at
    @events = Event.sorted_by_created_at
    @users = User.some_having_bio_and_avatar
    @post = @posts[0]
  end
end
