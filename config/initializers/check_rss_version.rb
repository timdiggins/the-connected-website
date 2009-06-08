require 'rss'
major, minor, point = RSS::VERSION.split('.').collect { |v| v.to_i }
#we need at least 0.2.1, so...
if major < 1 && (minor < 2 || (minor==2 && point < 1) ) 
  msg = "RSS::VERSION #{RSS::VERSION} not adequate.\nYou need to install new version.\nDownload tar file, unzip it anywhere, and then run: sudo ruby setup.rb \nto find tar file see http://raa.ruby-lang.org/project/rss/ or http://www.cozmixng.org/~rwiki/?cmd=view;name=RSS+Parser%3A%3AREADME.en"
  puts msg
  raise Exception.new(msg) 
end

# see also /lib/recipse/rss_parser.rb for cap
