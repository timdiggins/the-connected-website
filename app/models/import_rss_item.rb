require 'hpricot'

class ImportRssItem
  def initialize rss_feed, group, item
    @rss_feed = rss_feed
    @group = group
    @item = item
  end
  
  def exists?
      guid = ImportedGuid.find_by_rss_feed_id_and_guid(@rss_feed.id, @item.guid)
      !guid.nil? #we have already imported this item
  end
  
  def save
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
      guid.save if post.save
      self.class.parse_images_from_detail(detail).each do |src|
        post.post_images.new(:src=> src).save
      end
  end
  
  def self.parse_images_from_detail detail
    doc = Hpricot(detail)
    doc.search("img").collect { |elem| elem['src']} 
  end
  
end