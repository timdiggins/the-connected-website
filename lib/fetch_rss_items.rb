require File.dirname(__FILE__) + '/../app/models/rss_feed.rb'

class FetchRssItems
  def self.fetch_one
    begin
      rss_feed = RssFeed.find_next_to_fetch
      rss_feed.check_feed()
      return rss_feed
    rescue ActiveRecord::StaleObjectError
      #do nothing
    rescue ActiveRecord::RecordNotFound
      return false
    rescue
      puts "error #{$!} %s" % rss_feed
      return unless rss_feed
      rss_feed.update_attributes(:error_message=> "Unexpected error: #{$!}", :next_fetch => Time.now + 1.minute)
      return 
    end
  end
end