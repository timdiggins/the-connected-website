require File.dirname(__FILE__) + '/../test_helper'

class PostTest < ActiveSupport::TestCase
  
  should "ensure that the subscriber list for_ a post is unique" do
    post = new_post
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
  
  context "video_embed_tags" do
    should "should calculate ok fr youtube" do
      post = new_post
      assert_nil(post.video_embed_tags)
      
      post = new_post(:video => "     ")
      assert_nil(post.video_embed_tags)
      
      post.video = %Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
      assert_equal(post.video, post.video_embed_tags)
      
      post.video = %Q{Blah<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
      assert_nil(post.video_embed_tags)
      
      post.video = %Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/yCM_wQy4YVg&hl=en&fs=1&color1=0xe1600f&color2=0xfebd01" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>Hmmmm}
      assert_nil(post.video_embed_tags)
      
      #    post.video = %Q{http://www.youtube.com/watch}
      #    assert_nil(post.video_embed_tags)
      #    
      #    post.video = %Q{http://example/watch?v=FG2PUZoukfA}
      #    assert_nil(post.video_embed_tags)
      #    
      #    post.video = %Q{http://www.example.com/watch?v=FG2PUZoukfA}
      #    assert_nil(post.video_embed_tags)
      #
      #    post.video = %Q{http://www.youtube.com/watch?feature=related}
      #    assert_nil(post.video_embed_tags)
      
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
    
    should "allow embed tag blip tv to pass through" do
      post = new_post
      post.video = %Q{<embed src="http://blip.tv/play/lG3hz1eBolM" type="application/x-shockwave-flash" width="1024" height="798" allowscriptaccess="always" allowfullscreen="true"></embed>}
      assert_equal(post.video, post.video_embed_tags)
    end
    
    should "currently I think allow fr aritrary object tag to pass through" do
      post = new_post
      post.video = %Q{<object >some stuff</object>}
      assert_equal(post.video, post.video_embed_tags)
    end
    
    should "convert http urls to links" do
      post = new_post
      link = %Q{http://someurlorother.com/wherever}
      post.video = link
      assert(post.video_embed_tags.include?(%Q{<a href="#{link}" rel="nofollow">#{link}</a>}))
    end
  end
  
  should "require video appropriately" do
    post = new_post(:title => "Whatever", :detail => "Whatever")
    assert post.valid?
    
    post.specifying_video = true
    assert !post.valid?
    assert_equal(["Video can't be blank"], post.errors.full_messages)
    
    post.video = "HereHere"
    assert post.valid?
    
    post.detail = '   '
    assert post.valid?
  end
  
  
  
  should "calculate preview_image for_ video" do
    post = new_post
    expectedPreviewImage = nil 
    assert_equal(expectedPreviewImage, post.preview_image)
  end
  
  should "calculate preview_image_src for_ video" do
    post = new_post
    expectedPreviewImage = %Q{http://img.youtube.com/vi/FG2PUZoukfA/2.jpg} 
    
    post.video = %Q{http://youtube.com/watch?v=FG2PUZoukfA}
    assert_equal(expectedPreviewImage, post.preview_image)
    
    post.video = %Q{http://youtube.com/watch?v=FG2PUZoukfA\r\n\n}
    assert_equal(expectedPreviewImage, post.preview_image)
    
    post.video = %Q{http://www.youtube.com/watch?v=FG2PUZoukfA}
    assert_equal(expectedPreviewImage, post.preview_image)
  end
  
  should "initialize date fields correctly" do
    post = new_post(:title => "Whatever", :detail => "Whatever")
    assert post.valid?
    post.save!
    assert !post.created_at.nil?, "expected created at not to be nil"
    assert !post.updated_at.nil?, "expected updated at not to be nil"
    assert !post.commented_at.nil?, "expected commented at not to be nil"
    assert_equal post.created_at, post.commented_at
  end
  
  #context "post with comments" do
  #  should "be able to determine if user has already contributed " do
  #     post = posts(:alex_interesting_article)
  #     assert post.has_contributed?(users(:alex))
  #     assert ! post.has_contributed?(users(:fred))
  #     assert post.has_contributed?(users(:duff))
  #  end
  #  end
  
  def new_post *args
    groups(:studio1).posts.new *args
  end
  
  should "be able to have correct cached count" do
    post = new_post :title=>'spme title'
    post.save!
    assert_equal 0, Post.find(post.id).post_images_count
    i = post.images.new :src => 'some source'
    i.save!
    assert_equal 1, Post.find(post.id).post_images_count
    i.destroy
    assert_equal 0, Post.find(post.id).post_images_count
    
  end
  should "be able to know whether has images" do
    assert post_with_images_and_no_text.has_images?
    assert !post_with_images_and_no_text.has_text?
    
    assert !post_with_text_and_no_images.has_images?
    assert post_with_text_and_no_images.has_text?
  end
  
  should "be able to act as  display_as_images" do
    #initially
    assert_equal nil, post_with_text_and_no_images.images_only
    assert_equal nil, post_with_images_and_text.images_only
    assert_equal nil, post_with_images_and_no_text.images_only
    
    #should depend on whether there are images and no text
    assert_equal true, post_with_images_and_no_text.display_as_images?
    assert_equal false, post_with_images_and_text.display_as_images?
    assert_equal false, post_with_text_and_no_images.display_as_images?
    
    #with explicit false all should be false
    post_with_images_and_no_text.update_attributes(:images_only => false)
    post_with_images_and_text.update_attributes(:images_only => false)
    post_with_text_and_no_images.update_attributes(:images_only => false)
    assert_equal false, post_with_images_and_no_text.display_as_images?
    assert_equal false, post_with_images_and_text.display_as_images?
    assert_equal false, post_with_text_and_no_images.display_as_images?
    
    #with explicit true all should be true
    post_with_images_and_no_text.update_attributes(:images_only => true)
    post_with_images_and_text.update_attributes(:images_only => true)
    post_with_text_and_no_images.update_attributes(:images_only => true)
    assert_equal true, post_with_images_and_no_text.display_as_images?
    assert_equal true, post_with_images_and_text.display_as_images?
    assert_equal false, post_with_text_and_no_images.display_as_images?
    
  end
  
  context "Post class" do
    setup do
      TestUtil.recalculate_counters
    end
    
    should "be able to find recent posts without images" do
      posts = Post.with_no_images.all
      assert_equal 2, posts.size
      assert posts.include?(posts(:alex_boring_link))
      assert ! posts.include?(post_with_images_and_text)
      assert ! posts.include?(post_with_images_and_no_text)
    end
    
    should "be able to parse single image without width and height from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" />}
      got = Post.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal 'http://somwhereelse', got[0] 
    end 
    should "be able to parse single image with width and height from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" width="128" height="200" />}
      got = Post.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal 'http://somwhereelse', got[0] 
    end
    
    should "be able to parse tricksy image from wordpress html" do
      html = %Q{
      <p><img class="alignnone" style="border: 0px;" title="Chandigarh" src="http://farm3.static.flickr.com/2423/3699060452_fdb3a795bd_b.jpg" alt="" width="595" height="406" /></p>
<p><img class="alignnone" style="border: 0px;" title="Chandigarh" src="http://farm3.static.flickr.com/2658/3699067170_52d81f7b0d_b.jpg" alt="" width="595" height="406" /></p>
<p><img class="alignnone" style="border: 0px;" title="Chandigarh" src="http://farm4.static.flickr.com/3471/3698274039_e7a36d1e15_b.jpg" alt="" width="595" height="406" /></p>
<p><img class="alignnone" style="border: 0px;" title="Chandigarh" src="http://farm3.static.flickr.com/2444/3699124506_304e48c22e_b.jpg" alt="" width="595" height="406" /></p>
}
      got = Post.parse_images_from_detail(html)
      assert_equal 4,got.length
      assert_equal 'http://farm3.static.flickr.com/2423/3699060452_fdb3a795bd_b.jpg', got[0] 
      
    end

    
    
  end
  
end