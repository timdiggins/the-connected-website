require 'rss'
require 'open-uri'

class RssFeed < ActiveRecord::Base
  belongs_to :group
  has_many :imported_guids
  named_scope :sorted_by_next_fetch, lambda { { :order => "next_fetch ASC" }}
  
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
  def is_flickr?
    url.strip.starts_with? 'http://api.flickr.com'
  end
  
  def fixed_url
    u = url.strip
    return self.class.fix_url_for_flickr(u) if is_flickr?
    u
  end
  
  def self.fix_url_for_flickr url
    uri = URI.parse(url)
    fixed_query = uri.query.split('&').find_all{|q|
      name = q.split('=')[0]
      name!='format'
    }
    fixed_query << "format=rss_200"
    uri.query = fixed_query.join '&'
    uri.to_s
  end
  
  #class methods
  def self.fetch_one
    #return whether worth checking again soon
    rss_feed = activity = nil
    begin
      rss_feed = find_next_to_fetch!
      created_msg = rss_feed.check_feed()
      activity = "checked #{rss_feed.url}. #{created_msg}"
    rescue ActiveRecord::StaleObjectError
      #do nothing
      activity = "had a conflict with another rssfeedfetcher"
    rescue ActiveRecord::RecordNotFound
      #not worth checking again for a while
    rescue
      activity = "error #{$!} %s" % rss_feed
      puts activity 
      rss_feed.record_error("Unexpected error: #{$!}") if rss_feed
    end
    return activity
  end
  
  def self.fetch_one_unchecked
    rss_feed = find_next_to_fetch!
    rss_feed.check_feed()
  end
  
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
  
  
  #instance methods
  
  def check_feed
    created_msg = 'nothing'
    open(self.fixed_url) do |s|
      rsscontent = s.read
      created_msg = make_posts(rsscontent)
    end
    update_attributes(:last_fetched=>Time.now, :error_message=>"", :next_fetch => Time.now + 10.minute)
    created_msg
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
    created = 0
    ignored = 0
    group = self.group
    result.items.each_with_index do |item, i|
      rss_item = RssItem.new(self, group, item)
      if rss_item.exists?
        ignored+=1
      else      
        rss_item.import()
        created+=1
      end
    end
    "%s created, %s ignored" % [created, ignored]
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
  
  def has_problem?
    !error_message.blank?
  end
end
