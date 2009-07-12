#!/usr/bin/env ruby

root = File.expand_path(File.dirname(__FILE__) + '/../')
require root + '/config/environment'
require root + '/app/models/rss_feed'

loop do
  activity = RssFeed.fetch_one_unchecked
  if activity
    #got one... sleep for a bit just not to be a processor hog
    puts "#{Time.now.to_s :short} "
    sleep 5
  else
    puts "#{Time.now.to_s :short} nothing to do, wait for a bit"
    sleep 30
  end
end