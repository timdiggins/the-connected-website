require 'test_helper'
require 'fileutils'

class FlickrApiTest < ActiveSupport::TestCase
  include Exceptions
  
  context "FlickrApi" do
    setup do      
      @flickr_api = FlickrApi.new
    end
    
    should "be able to test echo failure from flickr" do
      # Get a Nokogiri::HTML:Document for the page weÕre interested in...
      begin
        @flickr_api.call(:method=>'flickr.test.echo', :name=>'value') { |rsp| }
        flunk 'should have given error'
      rescue Exception
        #ok
      end
    end
    
    should "be able to test echo success from flickr" do
      # Get a Nokogiri::HTML:Document for the page weÕre interested in...
      @flickr_api.call(:method=>"flickr.test.echo",:name=>'value') do |rsp|
        assert_equal 'value', rsp.xpath('./name')[0].content
        assert_equal 'flickr.test.echo', rsp.xpath('./method')[0].content
      end
    end
    
    should "be able to grab an image info from flickr" do
      farmurl = "http://farm4.static.flickr.com/3544/3323215853_c366b79672.jpg"
      photo_id = "3323215853"
      photo_secret = "c366b79672"
      @flickr_api.call(:method=>"flickr.photos.getInfo", :photo_id=>photo_id, :secret=>photo_secret) do |rsp|
        
      end
    end
    
    should "be able to grab biggest image sizes from flickr" do
      farmurl = "http://farm4.static.flickr.com/3544/3323215853_c366b79672.jpg"
      photo_id = "3323215853"
      photo_secret = "c366b79672"
      sizes = @flickr_api.flickr_image_sizes(photo_id, photo_secret)
      assert_equal "Original", sizes[0].label 
    end

        should "be able to figure out better flickr sizes" do
      assert_equal [], @flickr_api.flickr_images_sizes_fromurl('http://somewhereelse.com/somethign.png')
      sizes = @flickr_api.flickr_images_sizes_fromurl('http://farm4.static.flickr.com/3544/3323215853_c366b79672_m.jpg')
      assert_equal "Original", sizes[0].label
    end

    should "be able to figure out flickr stuff" do
      assert_equal [nil,nil], FlickrApi.flickr_photo_id_and_secret_fromurl('http://somewhereelse.com/somethign.png')
      assert_equal ['3323215853', 'c366b79672'], FlickrApi.flickr_photo_id_and_secret_fromurl('http://farm4.static.flickr.com/3544/3323215853_c366b79672_m.jpg')
    end

  end
end
