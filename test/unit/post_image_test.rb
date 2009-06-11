require 'test_helper'

class PostImageTest < ActiveSupport::TestCase
  
  should "be able to find featured images fer a group" do
    st1 = groups(:studio1)
    fi = st1.images.featured
    assert_equal 1, fi.count
    assert_equal post_images(:article_from_rss_image2).src, fi[0].src
    
    st3 = groups(:studio3)
    fi = st3.images.featured
    assert_equal 1, fi.count
    assert_equal post_images(:cool_article_image1).src, fi[0].src
  end
  
  should "be able to find all featured images" do
    fi = PostImage.featured
    assert_equal 2, fi.count
    assert_equal post_images(:cool_article_image1).src, fi[0].src
    assert_equal post_images(:article_from_rss_image2).src, fi[1].src
    
    fi2 = PostImage.featured.limit_to(1)
    assert_equal 1, fi2.all.size
    assert_equal post_images(:cool_article_image1).src, fi2[0].src
  end
  
  context "after assigning downloaded image post_image" do
    setup do
      image_downloader_setup
    end
    teardown do
      image_downloader_teardown
    end
    should "cache downloaded image sizes" do
      f = SAMPLE_IMAGE
      downloaded = ImageDownloader.new.store_downloaded_image(f, "image/jpeg")
      pi = post_images(:cool_article_image1)
      
      assert !pi.downloaded?, "precondition"
      pi.downloaded = downloaded 
      pi.save!
      
      pi = PostImage.find(post_images(:cool_article_image1).id)
      assert_equal [876,426],[pi.width, pi.height]
      assert_equal 658, pi.height320_width
      assert_equal 311, pi.width640_height
      assert pi.downloaded.is_a?(DownloadedImage)
    end
  end
end