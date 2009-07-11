require File.dirname(__FILE__) + '/../test_helper'

class ImportRssItemTest < ActiveSupport::TestCase
  
  context "Rss item" do
    should "be able to parse single image without width and height from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" />}
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal 'http://somwhereelse', got[0] 
    end 
    should "be able to parse single image with width and height from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" width="128" height="200" />}
      got = ImportRssItem.parse_images_from_detail(html)
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
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal 4,got.length
      assert_equal 'http://farm3.static.flickr.com/2423/3699060452_fdb3a795bd_b.jpg', got[0] 
      
    end
  end
end