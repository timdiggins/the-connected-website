require File.dirname(__FILE__) + '/../app/models/rss_feed.rb'

class FetchRssItems
  def self.fetch_one
    #return whether worth checking again soon
    activity = nil
    begin
      rss_feed = RssFeed.find_next_to_fetch!
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
      return unless rss_feed
      rss_feed.update_attributes(:error_message=> "Unexpected error: #{$!}", :next_fetch => Time.now + 1.minute)
    end
    return activity
  end
end