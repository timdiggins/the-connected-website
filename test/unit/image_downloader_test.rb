require 'test_helper'

SAMPLES_DIR = File.expand_path(File.dirname(__FILE__) + "/sample_images")

class ImageDownloaderTest < ActiveSupport::TestCase
  context "ImageDownloader" do
    setup do
      @downloader = ImageDownloader.new
    end
    should "be able to download an image and work out the mimetype" do
      url = 'http://www.wmin.ac.uk/sabe/images/marylebone_entrance5%20copy_v_Variation_1.jpg'
      path, mimetype = @downloader.fetch(url)
      assert_equal "#{TMP_DIR}/marylebone_entrance5%20copy_v_Variation_1.jpg", path
      assert File.exists?(path)
      assert_equal "image/jpeg", mimetype
    end
    
    should "be able to store as a downloaded_image" do
      f = "#{SAMPLES_DIR}/samplejpg.jpg"
      mimetype = "image/jpeg"
      pi = post_images(:cool_article_image1)
      @downloader.store_downloaded_image(pi, f, mimetype)
    end
  end
end