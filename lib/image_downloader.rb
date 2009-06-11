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
    filepath = "#{TMP_DIR}/#{File.basename(uri.path)}"
    File.delete(filepath) if File.exists?(filepath)
    better_flickr = flickr_replacement(url)
    if !better_flickr.nil?
      begin 
        mimetype = uri_to_filepath(better_flickr, filepath)
        return filepath, mimetype
      rescue
        puts "failed with better_flickr #{better_flickr}"
      end
    end
    mimetype = uri_to_filepath(uri, filepath)
    return filepath, mimetype
  end
  
  def uri_to_filepath(uri, filepath)
    remoteRio = rio(uri)
    rio(filepath) < remoteRio
    remoteRio.content_type
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
    filepath, mimetype = fetch(image.src)
    begin
      downloaded = store_downloaded_image(filepath, mimetype)
    rescue DownloadedImageTooSmall
      image.destroy
      return "deleted too small image #{image.src}"
    rescue Exception => e
      return "problem with #{image.src} : #{e}"
    end
    image.downloaded = downloaded
    image.save!
    return "fetched from #{image.src}"
  end

  
  def seek_one_imageless_text
    
  end
end
