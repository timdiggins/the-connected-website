require 'hpricot'

class RssItem
  include Exceptions 
  def initialize rss_feed, group, item
    @rss_feed = rss_feed
    @group = group
    @item = item
  end
  
  def exists?
    guid = ImportedGuid.find_by_rss_feed_id_and_guid(@rss_feed.id, @item.guid)
    !guid.nil? #we have already imported this item
  end
  
  def import
    guid = ImportedGuid.new(:rss_feed_id=>@rss_feed.id, :guid=>@item.guid) 
    title = @item.title 
    title = 'untitled' if title.nil? || title.strip.empty?
    detail = @item.content_encoded || @item.description || ''
    post = Post.new(
                    :title => title,
                    :detail => detail,
                    :remote_url=>@item.link,
                    :group_id=>@group.id
    )
    if !post.valid?
      puts "title: #{title}"
      puts "detail: #{detail}"
      puts "detail-sanitized: #{HTML::FullSanitizer.new.sanitize(detail)}"
      puts "remote_url: #{@item.link}"
      puts "group.id #{@group.id}"
      puts "couldn't validate post for group-#{@group.id}, #@group"
    end
    post.save!
    guid.save
    post.download_and_save_images_in_detail
  end
  
end