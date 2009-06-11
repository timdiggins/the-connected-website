require 'hpricot'

class ImportRssItem
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
    image_downloader = ImageDownloader.new
    self.class.parse_images_from_detail(detail).each do |image|
      if !image.nil?
        filepath, mimetype = image_downloader.fetch(image.src)
        begin
          downloaded = image_downloader.store_downloaded_image(filepath, mimetype)
        rescue DownloadedImageTooSmall
          image = nil#should really delete the anomalous downloaded image record'
        rescue Exception
          downloaded = nil
        end
        if !image.nil?
          if !downloaded.nil?
            image.downloaded = downloaded
          end
          image.post_id = post.id
          post.images << image
          image.save!
        end  
      end
    end
  end
  
  def self.parse_images_from_detail detail
    doc = Hpricot(detail)
    imgs = doc.search("img").collect do |elem| 
      src = elem['src']
#      width =  elem['width']
#      height =  elem['height']
      PostImage.new(:src=>src)
    end 
    imgs.compact
  end
  
end