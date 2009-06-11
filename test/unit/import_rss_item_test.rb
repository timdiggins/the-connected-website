require File.dirname(__FILE__) + '/../test_helper'

class ImportRssItemTest < ActiveSupport::TestCase
  
  context "Rss item" do
    should "be able to parse single image without width and height from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" />}
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal PostImage.new(:src=>'http://somwhereelse').attributes, got[0].attributes 
    end 
    should "be able to parse single image with width and height from html" do
      html = %Q{something easy for starters is <img src="http://somwhereelse" width="128" height="200" />}
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal PostImage.new(:src=>'http://somwhereelse', :width=>128, :height=>200).attributes, got[0].attributes 
    end 
    should "skip too small imgs" do
      html = %Q{some imgs 
      <img src="http://somwhereelse" width="100" height="200" />
      <img src="http://somwhereelse" width="200" height="100" />
      <img src="http://somwhereelse" width="100" height="100" />
      <img src="http://somwhereelseentirely" />
      }
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal PostImage.new(:src=>'http://somwhereelseentirely').attributes, got[0].attributes 
    end 

    should "skip too small remote imgs" do
      html = %Q{some imgs 
      <img src="http://somwhereelse" />
      <img src="http://somwhereelse" width="200" height="100" />
      <img src="http://somwhereelse" width="100" height="100" />
      <img src="http://somwhereelseentirely" />
      }
      got = ImportRssItem.parse_images_from_detail(html)
      assert_equal 1,got.length
      assert_equal PostImage.new(:src=>'http://somwhereelseentirely').attributes, got[0].attributes 
    end 
end
end