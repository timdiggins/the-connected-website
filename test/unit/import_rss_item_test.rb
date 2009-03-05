require File.dirname(__FILE__) + '/../test_helper'

class ImportRssItemTest < ActiveSupport::TestCase
  
  context "Rss item" do
    should "be able to parse single image from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" />}
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal ['http://somwhereelse'], got 
    end 
  end
end