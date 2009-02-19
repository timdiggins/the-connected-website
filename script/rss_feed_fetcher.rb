#!/usr/bin/env ruby

RAILS_ENV = ARGV[1] || 'development'

root = File.expand_path(File.dirname(__FILE__) + '/../')
require root + '/config/environment.rb'
require root + '/lib/fetch_rss_items.rb'

loop do
  rss_feed = FetchRssItems.fetch_one
  if rss_feed
    #got one... sleep for a bit just not to be a processor hog
    puts "#{Time.now.to_s :short} got #{rss_feed.url}"
    sleep 5
  else
    #didn't get one.... may as well wait for a bit
    puts "#{Time.now.to_s :short} didn't get one "
    sleep 30
  end
end