require 'test_helper'
require 'fileutils'

class ImageDownloaderTest < ActiveSupport::TestCase
  include Exceptions
  
  context "ImageDownloader" do
    setup do
      image_downloader_setup
      @downloader = ImageDownloader.new
    end
    teardown do
      image_downloader_teardown
    end
    should "be able to download an image and work out the mimetype" do
      url = 'http://www.wmin.ac.uk/sabe/images/marylebone_entrance5%20copy_v_Variation_1.jpg'
      path, mimetype = @downloader.fetch(url)
      assert_equal "#{TMP_DIR}/marylebone_entrance5%20copy_v_Variation_1.jpg", path
      assert File.exists?(path)
      assert_equal "image/jpeg", mimetype
    end
    
    should "be able to store as a downloaded_image" do
      f = SAMPLE_IMAGE
      mimetype = "image/jpeg"
      downloaded = @downloader.store_downloaded_image(f, mimetype)
      assert !downloaded.nil?, "should exist now"
      assert downloaded.is_a?(DownloadedImage)
    end
    
    should "be able to store as a downloaded_image" do
      assert_equal 0, DownloadedImage.all.size
      f = SAMPLE_TOO_SMALL_IMAGE
      mimetype = "image/jpeg"
      begin
        @downloader.store_downloaded_image(f, mimetype)
        flunk "shouldn't work"
      rescue DownloadedImageTooSmall
      end
      assert_equal 0, DownloadedImage.all.size
    end
    
    should "be able to find_next_to_postprocess" do
      image = @downloader.find_next_to_postprocess
      assert !image.nil?
      assert image.is_a? PostImage
    end
    
    should "be able to figure out better flickr address" do
      assert_equal nil, @downloader.flickr_replacement('http://somewhereelse.com/somethign.png')
      assert_equal 'http://farm4.static.flickr.com/3544/3323215853_c366b79672.jpg', @downloader.flickr_replacement('http://farm4.static.flickr.com/3544/3323215853_c366b79672_m.jpg')
    end
    
  end
end