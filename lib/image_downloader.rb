require File.dirname(__FILE__) + '/../app/models/downloaded_image.rb'
TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp")

require 'uri'
#require 'open-uri'
require 'rio'
# required to use ActionController::TestUploadedFile 
require 'action_controller'
require 'action_controller/test_process.rb'
require 'exceptions'

class ImageDownloader
  include Exceptions
  
  def fetch(url)
    begin
      uri = URI.parse(url)
    rescue
      raise "problem with url: #{url}"
    end
    better_flickr = flickr_replacement(url)
    if !better_flickr.nil?
      begin 
        return uri_to_filepath(better_flickr)
      rescue
        puts "failed with better_flickr #{better_flickr}"
      end
    end
    return uri_to_filepath(uri)
  end
  
  def uri_to_filepath(uri)
    filepath = "#{TMP_DIR}/#{File.basename(uri.path)}"
    File.delete(filepath) if File.exists?(filepath)
    remoteRio = rio(uri)
    rio(filepath) < remoteRio
    mimetype = remoteRio.content_type
    if File.extname(filepath)==""
      newfilepath = filepath+"."+mimetype.split('/')[-1]
      File.move(filepath, newfilepath)
      return mimetype, newfilepath
    end
    return mimetype, filepath
  end
  
  def flickr_replacement url
    m = /(http:\/\/farm[0-9].static.flickr.com\/[^\/]+\/[^\/]+)_m(.jpg)/.match(url)
    return nil if m.nil?
    m.captures.to_s
  end
  
  
  def store_downloaded_image(filepath, mimetype)
    data = ActionController::TestUploadedFile.new(filepath, mimetype)
    DownloadedImage.transaction do
      DownloadedImage.create!(:uploaded_data => data)
    end
  end
  
  def find_next_to_postprocess
    PostImage.find(:first, :conditions=>"downloaded_image_id is NULL")
  end
  
  def fetch_one
    image = find_next_to_postprocess
    return false if image.nil?
    begin
      filepath, mimetype = fetch(image.src)
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
  
  
  def seek_one_imageless_text
    
  end
end
