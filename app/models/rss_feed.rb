class RssFeed < ActiveRecord::Base
  belongs_to :group
  
  before_create do |rss_feed|
    if rss_feed.next_fetch.nil?
      rss_feed.next_fetch = Time.now 
    end
  end

  protected
  def validate
    errors.add('url', "must begin with either http:// or https://") unless url =~ /https?\:\/\//
  end
  public
  
  def self.find_next_to_fetch
    rss_feed = find(:first, :conditions=>{:last_fetched=>nil})
    return rss_feed unless rss_feed.nil?
    conditions = sanitize_sql_for_conditions({ :next_fetch=>Time.now.to_s(:db) })
    conditions = conditions.sub('=', '<=')
    puts conditions
    rss_feed = find(:first, :conditions=>"next_fetch <= '#{Time.now.to_s(:db)}'", :order=>'next_fetch')
    raise ActiveRecord::RecordNotFound if rss_feed.nil?
    puts "next %s fe:%s" % [ rss_feed.url, rss_feed.next_fetch]
    rss_feed
  end
  
  def check_feed
    puts 'doing the work of getting and making'
    update_attributes(:last_fetched=>Time.now, :error_message=>"", :next_fetch => Time.now + 10.minute)
  end
end
