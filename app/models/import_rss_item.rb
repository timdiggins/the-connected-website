require 'hpricot'
MIN_SIZE = 128
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
    self.class.parse_images_from_detail(detail).each do |image|
      if !image.nil?
        image.post_id = post.id
        post.images << image
        image.save
      end
    end
  end
  
  def self.parse_images_from_detail detail
    doc = Hpricot(detail)
    imgs = doc.search("img").collect do |elem| 
      src = elem['src']
      width =  elem['width']
      if !width.nil?
        width = width.to_i
        next if width < MIN_SIZE
      end
      height =  elem['height']
      if ! height.nil?
        height = height.to_i
        next if height < MIN_SIZE
      end
      PostImage.new(:src=>src, :width=>width, :height=>height)
    end 
    imgs.compact
  end
  
end