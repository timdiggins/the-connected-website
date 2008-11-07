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
    
    post.video = %Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
    assert_equal(post.video_embed_tags, post.video)
  end
end
