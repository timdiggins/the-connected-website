require 'test_helper'

class PostImageTest < ActiveSupport::TestCase

  should "be able to find featured images for a group" do
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

end
