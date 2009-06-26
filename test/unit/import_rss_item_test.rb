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
  end
end