require 'rss'
require 'open-uri'

class RssFeed < ActiveRecord::Base
  belongs_to :group
  has_many :imported_guids
  
  #  before_create do |rss_feed|
  #    if rss_feed.next_fetch.nil?
  #      rss_feed.next_fetch = Time.now 
  #    end
  #  end
  
  protected
  def validate
    errors.add('url', "must begin with either http:// or https://") unless url =~ /https?\:\/\//
  end
  public
  
  def self.find_next_to_fetch!
    rss_feed = find(:first, :conditions=>{:next_fetch=>nil})
    return rss_feed unless rss_feed.nil?
    #    conditions = sanitize_sql_for_conditions({ :next_fetch=>Time.now.to_s(:db) })
    #    conditions = conditions.sub('=', '<=')
    conditions ="next_fetch <= '#{Time.now.utc.to_s(:db)}'"
    rss_feed = find(:first, :conditions=>conditions, :order=>'next_fetch')
    raise ActiveRecord::RecordNotFound if rss_feed.nil?
    rss_feed
  end
  
  def check_feed
#    puts 'doing the work of getting and making'
    open(self.url) do |s|
      rsscontent = s.read
      make_posts(rsscontent)
    end
    update_attributes(:last_fetched=>Time.now, :error_message=>"", :next_fetch => Time.now + 10.minute)
  end  
  
  def record_error error_message
    update_attributes(:error_message=> error_message, :next_fetch => Time.now + 1.minute)
  end
  
  def make_posts(rsscontent)
    #fix for flickr badness:
    #http://groups.google.com/group/vanrb/browse_thread/thread/f567054d82de21c
    rsscontent.gsub!( 'date.Taken', 'dateTaken' ) 
    
    result = RSS::Parser.parse(rsscontent, false)
    #    attrs[:title] = result.channel.title
    group = self.group
    result.items.each_with_index do |item, i|
      import_item = ImportRssItem.new(self, group, item)
      import_item.save() unless import_item.exists?    
    end
  end
  
  def to_s
    s = <<TEXT
Rss Feed(
  for '%s' 
  by '%s'
  last fetched %s%s
  next fetch at %s
  )
TEXT
    return s %[
url, group,
     last_fetched,
    error_message.blank? ? '': "\n  gave error:#{error_message}",
    next_fetch
    ]
  end
end
