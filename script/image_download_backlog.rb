#!/usr/bin/env ruby

root = File.expand_path(File.dirname(__FILE__) + '/../')
require root + '/config/environment'
require root + '/lib/image_download'

loop do
  activity = ImageDownload.fetch_one
  if activity
    #got one... sleep for a bit just not to be a processor hog
    puts "#{Time.now.to_s :short} #{activity}"
    sleep 2
  else
    puts "#{Time.now.to_s :short} nothing to do, wait for a bit"
    sleep 30
  end
end