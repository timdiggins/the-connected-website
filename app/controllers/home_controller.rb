class HomeController < ApplicationController
  def index

    
    
    @events = Event.sorted_by_created_at.without_tagging_events.limit_to(5)
    @latest_event = Event.sorted_by_created_at.first
    @users = User.has_bio_and_avatar.recently_contributed(3)
    @tags = Tag.all_with_count :limit=>20
    @groups = Group.all
    
    @featured = PostImage.find(:all, :include => :post, :limit=>50)
  end
end
