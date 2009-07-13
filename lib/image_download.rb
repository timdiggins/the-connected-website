require File.dirname(__FILE__) + '/../app/models/downloaded_image.rb'
TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp")

require 'uri'
#require 'open-uri'
require 'fileutils'
require 'rio'
# required to use ActionController::TestUploadedFile 
require 'action_controller'
require 'action_controller/test_process.rb'
require 'exceptions'

class ImageDownload
  include Exceptions
  
  def initialize url, flickr_api=nil
    @url = url
    begin
      @uri = URI.parse(url)
    rescue
      raise "problem with url: #{url}"
    end
    flickr_api = FlickrApi.new if flickr_api.nil?
    @flickr_api = flickr_api
  end
  
  def fetch
    @flickr_api.flickr_images_sizes_fromurl(@url).each do |flickr_size|
      begin 
        puts "trying #{flickr_size.source}"
        return uri_to_filepath(URI.parse(flickr_size.source))
      rescue Exception => e
        puts e
        puts "failed with better_flickr #{flickr_size.source}"
      end
    end
    return uri_to_filepath(@uri)
  end
  
  def fetch_caption
    begin 
      return @flickr_api.caption_from_url(@url)
    rescue Exception => e
      puts "fetch_caption from #{@url} raised '#{e}'"
    end
    return nil
  end
  
  def uri_to_filepath(uri)
    filepath = "#{TMP_DIR}/#{File.basename(uri.path)}"
    File.delete(filepath) if File.exists?(filepath)
    remoteRio = rio(uri)
    rio(filepath) < remoteRio
    mimetype = remoteRio.content_type
    if File.extname(filepath)==""
      newfilepath = filepath+"."+(mimetype.split('/')[-1])
      FileUtils.move(filepath, newfilepath)
      return newfilepath, mimetype
    end
    return filepath, mimetype
  end
  
  
  
  def self.store_downloaded_image(filepath, mimetype)
    RAILS_DEFAULT_LOGGER.info '***about to start transaction****'
    data = ActionController::TestUploadedFile.new(filepath, mimetype)
    DownloadedImage.transaction do
      RAILS_DEFAULT_LOGGER.info '***inside transaction****'
      DownloadedImage.create!(:uploaded_data => data)
    end
  end
  
  def self.find_next_to_postprocess
    PostImage.find(:first, :conditions=>"downloaded_image_id is NULL")
  end
  
  def self.fetch_one
    image = find_next_to_postprocess
    return false if image.nil?
    begin
      image_download = self.new
      filepath, mimetype = image_download.fetch(image.src)
      downloaded = store_downloaded_image(filepath, mimetype)
    rescue DownloadedImageTooSmall
      image.destroy
      return "deleted too small image #{image.src}"
    rescue OpenURI::HTTPError => e
      image.destroy
      return "delete image couldn't find #{image.src} : #{e}"
    rescue Exception => e
      return "problem with #{image.src} : #{e}\nhttp://openstudiowestminster.org/posts/#{image.post.id}"	
    end
    image.downloaded = downloaded
    image.save!
    return "fetched from #{image.src}"
  end
  
end
