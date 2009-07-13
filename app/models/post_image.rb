class PostImage < ActiveRecord::Base
  include Exceptions
  
  belongs_to :post, :counter_cache=> true
  
  named_scope :featured, lambda { { :conditions => [ "post_images.featured_at IS NOT NULL" ], :order => "post_images.featured_at DESC" }} 
  named_scope :featured3, lambda { { :order => "post_images.featured_at DESC", :limit=>3}} 
  named_scope :limit_to, lambda { | limit | { :limit => limit } }
  
  belongs_to :downloaded_image, :dependent => :destroy 
  
  alias_attribute :downloaded, :downloaded_image
  
  before_save :cache_downloaded_sizes
  
  @@image_download_class = ImageDownload 
  
  cattr_accessor :image_download_class
  
  
  def cache_downloaded_sizes  
    return if !downloaded?
    self.width = downloaded_image.width
    self.height = downloaded_image.height
    self.downloaded_image.thumbnails.each do |thumbnail|
      if thumbnail.thumbnail == 'height320'
        self.height320_width = thumbnail.width
      elsif thumbnail.thumbnail == 'width640'
        self.width640_height = thumbnail.height
      end
    end
  end
  
  def width_for_height(h)
    return nil if self.width.nil? || self.height.nil? 
    h*self.width/self.height
  end
  def height_for_width(w)
    return nil if self.width.nil? || self.height.nil?
    w*self.height/self.width
  end
  
  def featured?
    !featured_at.nil?
  end
  
  def downloaded?
    !downloaded_image.nil?
  end
  
  def download_and_save!
    image_download = @@image_download_class.new src  
    filepath, mimetype = image_download.fetch
    begin
      self.downloaded = @@image_download_class.store_downloaded_image(filepath, mimetype)
    rescue DownloadedImageTooSmall
      #should really delete the anomalous downloaded image record'
      return false
    rescue Exception => e
      save!
      raise DownloadError.new("problem trying to download image \n  src: #{src}\n  e  : #{e}")
    end
    self.caption = image_download.fetch_caption
    save!
  end
end
