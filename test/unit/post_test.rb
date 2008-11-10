require File.dirname(__FILE__) + '/../test_helper'

class PostTest < ActiveSupport::TestCase

  should "ensure that the subscriber list for a post is unique" do
    post = Post.new
    assert_equal([], post.subscribers)
    
    duff = users(:duff)
    alex = users(:alex)
    post.subscribers << duff
    post.subscribers << duff
    post.subscribers << duff
    post.subscribers << alex
    post.subscribers << alex
    post.subscribers << duff
    assert_equal([duff, alex], post.subscribers)
    
    post.subscribers.delete(alex)
    assert_equal([duff], post.subscribers)
  end
  
  should "calculate video_embed_tags" do
    post = Post.new
    assert_nil(post.video_embed_tags)
    
    post = Post.new(:video => "     ")
    assert_nil(post.video_embed_tags)
    
    post.video = %Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
    assert_equal(post.video, post.video_embed_tags)

    post.video = %Q{http://www.youtube.com/watch}
    assert_nil(post.video_embed_tags)
    
    post.video = %Q{http://example/watch?v=FG2PUZoukfA}
    assert_nil(post.video_embed_tags)
    
    post.video = %Q{http://www.example.com/watch?v=FG2PUZoukfA}
    assert_nil(post.video_embed_tags)

    post.video = %Q{http://www.youtube.com/watch?feature=related}
    assert_nil(post.video_embed_tags)
    
    post.video = "Totally BogusUrl"
    assert_nil(post.video_embed_tags)
    
    post.video = %Q{http://www.youtube.com/watch?v=ez5robAWmu4&feature=related}
    assert_equal(%Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/ez5robAWmu4&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/ez5robAWmu4&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}, post.video_embed_tags)
    
    post.video = %Q{http://youtube.com/watch?v=FG2PUZoukfA}
    assert_equal(%Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/FG2PUZoukfA&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/FG2PUZoukfA&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>} , post.video_embed_tags)

    post.video = %Q{http://youtube.com/watch?v=FG2PUZoukfA\r\n\n}
    assert_equal(%Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/FG2PUZoukfA&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/FG2PUZoukfA&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>} , post.video_embed_tags)
    
    post.video = %Q{http://www.youtube.com/watch?v=FG2PUZoukfA}
    assert_equal(%Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/FG2PUZoukfA&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/FG2PUZoukfA&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>} , post.video_embed_tags)
  end
  
  should "require video appropriately" do
    post = Post.new(:title => "Whatever", :detail => "Whatever")
    assert post.valid?
    
    post.specifying_video = true
    assert !post.valid?
    assert_equal(["Video can't be blank"], post.errors.full_messages)
    
    post.video = "HereHere"
    assert post.valid?
    
    post.detail = '   '
    assert post.valid?
    
  end
  
end
