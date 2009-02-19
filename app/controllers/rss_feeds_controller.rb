class RssFeedsController < ApplicationController
  before_filter :login_required
  
  def create 
    @group = Group.find_by_name params[:group_id]
    raise PermissionDenied unless current_user.can_moderate? @group 
    @rss_feed = @group.rss_feeds.new
    @rss_feed.url = params[:rss_feed][:url]
    if @rss_feed.save
      flash[:notice] = "Added rss feed #{@rss_feed.url}"
    else
      flash[:error] = "Couldn't add rss feed #{@rss_feed.url}"
    end
    redirect_to group_rss_feeds_url
  end
  
  def destroy
    rss_feed = RssFeed.find_by_id(params[:id])
    raise PermissionDenied unless current_user.can_moderate? rss_feed.group
    rss_feed.destroy
    redirect_to group_rss_feeds_url
  end
  
  def index
    @group = Group.find_by_name params[:group_id]
    raise PermissionDenied unless current_user.can_moderate? @group 
    @rss_feed = @group.rss_feeds.new
  end
end
