require File.dirname(__FILE__) + '/../app/models/rss_feed.rb'

class FetchRssItems
  def self.run
      begin
        rss_feed = RssFeed.find_next_to_fetch(1.minutes)
        rss_feed.check_feed()
        
      rescue ActiveRecord::StaleObjectError
        #do nothing
      rescue ActiveRecord::RecordNotFound
        sleep 30
      rescue
        return unless rss_item
          rss_item.update_attributes(:error_message=> "Unexpected error: #{$!}", :next_fetch => Time.now + 1.minute)
          return
      end
  end
end