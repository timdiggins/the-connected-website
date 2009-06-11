require File.dirname(__FILE__) + '/../app/models/downloaded_image.rb'
TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp")

require 'uri'
#require 'open-uri'
require 'rio'
class ImageDownloader

  def fetch(url)
    uri = URI.parse(url)
    storeF = "#{TMP_DIR}/#{File.basename(uri.path)}"
    File.delete(storeF) if File.exists?(storeF)
    remoteRio = rio(uri)
    rio(storeF) < remoteRio
      mimetype = remoteRio.content_type
    return storeF, mimetype
  end
end