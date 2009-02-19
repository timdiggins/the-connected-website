require File.dirname(__FILE__) + '/../test_helper'

class RssFeedTest < ActiveSupport::TestCase

  context "Rss Feed" do
    should "be initialized with a next fetch now" do
      rss_feed = groups(:studio1).rss_feeds.new :url=>'http://something'
      rss_feed.save!
      assert rss_feed.next_fetch < Time.now + 1 

      rss_feed = rss_feeds(:long_ago_fetched_feed)
      assert rss_feed.next_fetch < (Time.now - 9.minutes)

      rss_feed = rss_feeds(:never_fetched_feed)
      assert rss_feed.next_fetch < Time.now + 1 

      rss_feed = rss_feeds(:just_fetched_feed)
      assert rss_feed.next_fetch > Time.now + 1 
    end
    
    should "be able to create stuff" do
      rss_feed = rss_feeds(:just_fetched_feed)
      assert 0, groups(:studio3).posts.count
      
      rss_feed.check_feed()
      postcount_afterfirst = groups(:studio3).posts.count 
      assert postcount_afterfirst > 5
      
      rss_feed.check_feed()
      assert_equal postcount_afterfirst, groups(:studio3).posts.count
    end
  end
  
  should "be able to get next feeds to fetch" do
    rss_feed = RssFeed.find_next_to_fetch
    assert_equal rss_feeds(:never_fetched_feed).id, rss_feed.id 
    rss_feed.update_attributes(:last_fetched=>Time.now, :next_fetch => Time.now + 10.minute)
    
    rss_feed = RssFeed.find_next_to_fetch
    assert_equal rss_feeds(:long_ago_fetched_feed), rss_feed 
    rss_feed.update_attributes(:last_fetched=>Time.now, :next_fetch => Time.now + 10.minute)
    
    rss_feed = RssFeed.find_next_to_fetch
    assert_equal rss_feeds(:recently_fetched_feed).id, rss_feed.id 
    rss_feed.update_attributes(:last_fetched=>Time.now, :next_fetch => Time.now + 10.minute)
    
    begin 
      rss_feed = RssFeed.find_next_to_fetch
      flunk "expected error but got #{rss_feed.url}"
    rescue ActiveRecord::RecordNotFound
    end
    
  end
end