require File.dirname(__FILE__) + '/../app/models/rss_feed.rb'

class FetchRssItems
  def self.fetch_one
    #return whether worth checking again soon
    begin
      rss_feed = RssFeed.find_next_to_fetch
      rss_feed.check_feed()
    rescue ActiveRecord::StaleObjectError
      #do nothing
    rescue ActiveRecord::RecordNotFound
      #not worth checking again for a while
      return false
    rescue
      puts "error #{$!} %s" % rss_feed
      return unless rss_feed
      rss_feed.update_attributes(:error_message=> "Unexpected error: #{$!}", :next_fetch => Time.now + 1.minute)
    end
    return true
  end
end