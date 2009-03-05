#!/usr/bin/env ruby

root = File.expand_path(File.dirname(__FILE__) + '/../')
require root + '/config/environment'
require root + '/lib/fetch_rss_items'

loop do
  rss_feed = FetchRssItems.fetch_one
  if rss_feed
    #got one... sleep for a bit just not to be a processor hog
    puts "#{Time.now.to_s :short} checked #{rss_feed.url}"
    sleep 5
  else
    puts "#{Time.now.to_s :short} nothing to do, wait for a bit"
    sleep 30
  end
end