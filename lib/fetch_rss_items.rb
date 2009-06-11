require File.dirname(__FILE__) + '/../app/models/rss_feed.rb'

class FetchRssItems
  def self.fetch_one
    #return whether worth checking again soon
    rss_feed = activity = nil
    begin
      rss_feed = next_rss_feed
      rss_feed.check_feed()
      activity = "checked #{rss_feed.url}"
    rescue ActiveRecord::StaleObjectError
      #do nothing
      activity = "had a conflict with another rssfeedfetcher"
    rescue ActiveRecord::RecordNotFound
      #not worth checking again for a while
    rescue
      activity = "error #{$!} %s" % rss_feed
      puts activity 
      rss_feed.record_error("Unexpected error: #{$!}") if rss_feed
    end
    return activity
  end
  
  def self.next_rss_feed
    RssFeed.find_next_to_fetch!
  end
  
  def self.fetch_one_unchecked
    rss_feed = next_rss_feed
    rss_feed.check_feed()
  end
  
end