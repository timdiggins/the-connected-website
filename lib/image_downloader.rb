require File.dirname(__FILE__) + '/../app/models/downloaded_image.rb'
TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp")

require 'uri'
#require 'open-uri'
require 'rio'
# required to use ActionController::TestUploadedFile 
require 'action_controller'
require 'action_controller/test_process.rb'


class ImageDownloader
  
  def fetch(url)
    begin
      uri = URI.parse(url)
    rescue
     raise "problem with url: #{url}"
    end
    filepath = "#{TMP_DIR}/#{File.basename(uri.path)}"
    File.delete(filepath) if File.exists?(filepath)
    remoteRio = rio(uri)
    rio(filepath) < remoteRio
    mimetype = remoteRio.content_type
    return filepath, mimetype
  end
  
  def store_downloaded_image(filepath, mimetype)
    data = ActionController::TestUploadedFile.new(filepath, mimetype)
    DownloadedImage.create!(:uploaded_data => data)
  end
  
end