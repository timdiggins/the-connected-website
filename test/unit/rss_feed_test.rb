require File.dirname(__FILE__) + '/../test_helper'

require File.dirname(__FILE__) + '/../../lib/image_downloader.rb'
class ImageDownloaderStubbed
  @@counter = 0
  
  def fetch(url)
    #    puts "Fake ImageDownloader [#@@counter] for test -> fake test #{url}"
    @@counter += 1
    if @@counter % 2==0
      print '+'
      return SAMPLE_IMAGE, "image/jpeg"
    else
      print '-'
      return SAMPLE_TOO_SMALL_IMAGE, "image/gif"
    end
  end
end

class RssFeedTest < ActiveSupport::TestCase
  setup do
    PostImage.image_downloader_class = ImageDownloaderStubbed
  end
  teardown do
    PostImage.image_downloader_class = ImageDownloader
  end
  context "Rss Feed" do
    should "be initialized with a next fetch nil" do
      rss_feed = never_fetched_feed!
      assert rss_feed.next_fetch.nil?
      
      rss_feed = rss_feeds(:long_ago_fetched_feed)
      assert rss_feed.next_fetch < (Time.now - 9.minutes)
      
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
    
    should "be able to import a flickrfeed" do
      rss_feed = never_fetched_feed! groups(:studio3)
      
      initial_postcount = groups(:studio3).posts.count 
      File.open(sample_feed("flickrfeed")) do |f|
        rss_feed.make_posts f.read
      end
      assert initial_postcount < groups(:studio3).posts.count
    end
    
    should "be able to import a images in a feed" do
      rss_feed = rss_feeds(:just_fetched_feed)
      initial_postcount = groups(:studio3).posts.count 
      File.open(sample_feed("ds04_singlepost")) do |f|
        rss_feed.make_posts f.read
      end
      assert_equal initial_postcount+1, groups(:studio3).posts.count
      imported = groups(:studio3).posts[-1]
      assert_equal 'Milos: plaster casts', imported.title
      assert_equal %Q{<p><a href="http://www.flickr.com/photos/ds04/sets/72157614578740902/" target="_blank"><img class="alignnone" title="maze pattern" src="http://farm4.static.flickr.com/3520/3316712556_52180f7a3b.jpg?v=0" alt="" width="239" height="115" /></a></p>
<p>see this 1 and many more on ds04 flickr</p>}, imported.detail.strip
    end
  end
  
  def sample_feed(name)
    File.dirname(__FILE__) + "/sample_feeds/#{name}.rss"
  end
  
  should "be able to get next feeds to fetch" do
    never_fetched_feed = never_fetched_feed!
    rss_feed = RssFeed.find_next_to_fetch!
    
    assert_equal never_fetched_feed, rss_feed
    postpone_feed rss_feed
    
    rss_feed = RssFeed.find_next_to_fetch!
    assert_equal rss_feeds(:long_ago_fetched_feed), rss_feed 
    postpone_feed rss_feed
    
    rss_feed = RssFeed.find_next_to_fetch!
    assert_equal rss_feeds(:recently_fetched_feed), rss_feed 
    postpone_feed rss_feed
    
    begin 
      rss_feed = RssFeed.find_next_to_fetch!
      flunk "expected error but at #{Time.now} got #{rss_feed}"
    rescue ActiveRecord::RecordNotFound
    end
    
  end
  

  
  def never_fetched_feed! for_group = nil
    if for_group.nil?
      for_group = groups(:studio1)
    end
    rss_feed = for_group.rss_feeds.new :url=>'http://something'
    rss_feed.save!
    rss_feed
  end
  
  def postpone_feed rss_feed 
    rss_feed.update_attributes(:last_fetched=>Time.now, :next_fetch => Time.now + 10.minute)
  end
  
  
  
end