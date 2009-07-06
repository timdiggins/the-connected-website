require "#{File.dirname(__FILE__)}/../test_helper"

class PostingTest < ActionController::IntegrationTest
  
  should "not be able to see the new post page if  logged in" do
    get_ok '/posts/new'
    assert_redirected_to '/login'
  end
  
  should "be able to see the new post page if  logged in" do
    new_session_as(:duff) do
      get_ok '/posts/new'
      assert_select "#contentTypes"
      assert_select "ul li.video"
      assert_select "ul li.file"
    end
  end
  should "be able to see the new create a text post page if  logged in" do
    new_session_as(:duff) do
      get_ok '/posts/new/text'
      assert_select "form#new_post"
    end
  end
  
  should "not be able to edit a post if  the author" do
    post_id = posts(:cool_article).id
    get_ok "/posts/#{post_id}"
    assert_link_does_not_exist EDIT_POST_LINK
    
    new_session_as(:alex) do
      get_ok "/posts/#{post_id}"
      assert_link_does_not_exist EDIT_POST_LINK
    end
  end
  
  should "be able to edit a post if  the author" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      get_ok "/posts/#{post_id}"
      click_link EDIT_POST_LINK
      
      put_via_redirect "/posts/#{post_id}", :post => { :title => "Government is Really Bogus", :detail => "Here is the body" }
      assert_response 200
      assert_select "h1.header", "Government is Really Bogus"
      assert_select "div.postBody", "Here is the body"
    end
  end
  
  
  #  context "creating and then editing a post" do
  #    setup do
  #      @duff = new_session_as(:duff)
  #      @duff.post_via_redirect "/posts", :post => { :title => "Something new in sandwiches", :detail => "Sandwich filling", :group_id => groups(:studio3).id }
  #      @post_id = @duff.path.split('/')[-1]
  #      @duff.get_ok("/")
  #      @duff.assert_select ".events .event a[href=/posts/#@post_id]", :count => 1
  #    end
  #    
  #    should "make one event if no comments" do
  #      @duff.put_via_redirect "/posts/#@post_id", :post => { :title => "New Sandwich Title", :detail => "new filling" }
  #      @duff.get_ok("/")
  #      @duff.assert_select ".events .event a[href=/posts/#@post_id]", :count => 1
  #    end
  #    
  #    should "make two events if comment has occurred" do
  #      alex = new_session_as(:alex)
  #      alex.post_via_redirect "/posts/#@post_id/comments", :comment => { :body => "jam tomorrow" }
  #      @duff.put_via_redirect "/posts/#@post_id", :post => { :title => "New Sandwich Title", :detail => "new filling" }
  #      @duff.get_ok("/")
  #      @duff.assert_select ".events .event a[href=/posts/#@post_id]", :count => 3
  #    end
  #    
  #    
  #  end
  
  should "only be able to delete a post if  a the manager of it" do
    new_session_as(:duff) do
      post_id = posts(:article_from_rss).id
      get_ok "/posts/#{post_id}"
      assert_link_does_not_exist "Delete post"
    end
    
    new_session_as(:alex) do
      #because alex_can_moderate_studio1
      post_id = posts(:article_from_rss).id
      get_ok "/posts/#{post_id}"
      assert_link_exists "Delete post"
      delete_via_redirect "/posts/#{post_id}"
      get "/posts/#{post_id}"
      assert_response 404
    end
  end
  should "only be able to delete or feature an image if  a the manager of it" do
    new_session_as(:duff) do
      post_id = posts(:article_from_rss).id
      get_ok "/posts/#{post_id}"
      i1 = post_images(:article_from_rss_image1)
      i2 = post_images(:article_from_rss_image2)
      assert_select "#image-#{i2.id}", :count=>0
    end
    
    new_session_as(:alex) do
      #because alex_can_moderate_studio1
      post_id = posts(:article_from_rss).id
      get_ok "/posts/#{post_id}"
      i1 = post_images(:article_from_rss_image1)
      i2 = post_images(:article_from_rss_image2)
      assert_select "#image-#{i1.id}" do
        assert_link_exists FEATURE_IMAGE_LINK
        assert_link_does_not_exist UNFEATURE_IMAGE_LINK
        assert_link_exists DELETE_IMAGE_LINK
      end
      assert_select "#image-#{i2.id}" do 
        assert_link_exists UNFEATURE_IMAGE_LINK
        assert_link_does_not_exist DELETE_IMAGE_LINK
        assert_link_does_not_exist FEATURE_IMAGE_LINK
      end
      delete_via_redirect "/images/#{i2.id}"
      get "/posts/#{post_id}"
      assert_select "#image-#{i2.id}", :count=>0
      
      put_via_redirect "/images/#{i1.id}/feature"
      get "/posts/#{post_id}"
      assert_select "#image-#{i1.id}" do 
        assert_link_exists UNFEATURE_IMAGE_LINK
        assert_link_does_not_exist FEATURE_IMAGE_LINK
      end
      put_via_redirect "/images/#{i1.id}/unfeature" 
      get "/posts/#{post_id}"
      assert_select "#image-#{i1.id}" do 
        assert_link_exists FEATURE_IMAGE_LINK
        assert_link_does_not_exist UNFEATURE_IMAGE_LINK
      end
    end
  end
end
EDIT_POST_LINK = "Edit post details"
DELETE_IMAGE_LINK = "Delete this image?"
FEATURE_IMAGE_LINK = "Feature on group and home page"
UNFEATURE_IMAGE_LINK = "Unfeature"