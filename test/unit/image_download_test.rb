require 'test_helper'
require 'fileutils'

class ImageDownloadTest < ActiveSupport::TestCase
  include Exceptions
  self.use_transactional_fixtures = false
  
  context "ImageDownload" do
    setup do
      image_download_setup
    end
    teardown do
      image_download_teardown
    end
    
    should "be able to download an image and work out the mimetype" do
      url = 'http://www.wmin.ac.uk/sabe/images/marylebone_entrance5%20copy_v_Variation_1.jpg'
      path, mimetype = ImageDownload.new(url).fetch
      assert_equal "#{TMP_DIR}/marylebone_entrance5%20copy_v_Variation_1.jpg", path
      assert File.exists?(path)
      assert_equal "image/jpeg", mimetype
    end
    
    should "be able to store as a downloaded_image" do
      f = SAMPLE_IMAGE
      mimetype = "image/jpeg"
      downloaded = ImageDownload.store_downloaded_image(f, mimetype)
      assert !downloaded.nil?, "should exist now"
      assert downloaded.is_a?(DownloadedImage)
    end
    
    should "be able to store as a downloaded_image" do
      assert_equal 0, DownloadedImage.all.size
      f = SAMPLE_TOO_SMALL_IMAGE
      mimetype = "image/jpeg"
      begin
        ImageDownload.store_downloaded_image(f, mimetype)
        flunk "shouldn't work"
      rescue DownloadedImageTooSmall
      end
      DownloadedImage.all.each {|img| puts img}
      assert_equal 0, DownloadedImage.all.size
    end
    
    should "be able to find_next_to_postprocess" do
      image = ImageDownload.find_next_to_postprocess
      assert !image.nil?
      assert image.is_a?(PostImage)
    end
    
  end
end