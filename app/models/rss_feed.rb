require 'rss'
require 'open-uri'

class RssFeed < ActiveRecord::Base
  belongs_to :group
  has_many :imported_guids
  
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
    rss_feed = find(:first, :conditions=>"next_fetch <= '#{Time.now.to_s(:db)}'", :order=>'next_fetch')
    raise ActiveRecord::RecordNotFound if rss_feed.nil?
    rss_feed
  end
  
  def check_feed
    puts 'doing the work of getting and making'
    open_url
    update_attributes(:last_fetched=>Time.now, :error_message=>"", :next_fetch => Time.now + 10.minute)
  end
  
  def open_url
    url = self.url
    rsscontent = nil
    open(url) do |s|
      rsscontent = s.read
      make_posts(rsscontent)
    end
  end
  
  def make_posts(rsscontent) 
    result = RSS::Parser.parse(rsscontent, false)
#    attrs[:title] = result.channel.title
    group = self.group
    result.items.each_with_index do |item, i|
      guid = ImportedGuid.find_by_rss_feed_id_and_guid(self.id, item.guid)
      return unless guid.nil?
      ImportedGuid.new(:rss_feed_id=>self.id, :guid=>item.guid).save! 
      post = Post.new (
      :title =>item.title,
      :detail =>item.description,
      :remote_url=>item.link,
      :group_id=>group.id
      )
      post.save!
    end
  end

end
