require "#{File.dirname(__FILE__)}/../test_helper"

class PostingTest < ActionController::IntegrationTest
  
  should "not be able to see the new post page if you're logged in" do
    get_ok '/posts/new'
    assert_redirected_to '/login'
  end
  
  should "be able to see the new post page if you're logged in" do
    new_session_as(:duff) do
      get_ok '/posts/new'
      assert_select "#contentTypes"
      assert_select "ul li.video"
      assert_select "ul li.file"
    end
  end
  should "be able to see the new create a text post page if you're logged in" do
    new_session_as(:duff) do
      get_ok '/posts/new/text'
      assert_select "form#new_post"
    end
  end
  
  should "not be able to edit a post if you're the author" do
    post_id = posts(:cool_article).id
    get_ok "/posts/#{post_id}"
    assert_link_does_not_exist "Edit post"
    
    new_session_as(:alex) do
      get_ok "/posts/#{post_id}"
      assert_link_does_not_exist "Edit post"
    end
  end
  
  should "be able to edit a post if you're the author" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      get_ok "/posts/#{post_id}"
      click_link "Edit post"
      
      put_via_redirect "/posts/#{post_id}", :post => { :title => "Government is Really Bogus", :detail => "Here is the body" }
      assert_response 200
      assert_select "h1.post", "Government is Really Bogus"
      assert_select "div.postBody", "Here is the body"
    end
  end
  
  
  context "creating and then editing a post" do
    setup do
      @duff = new_session_as(:duff)
      @duff.post_via_redirect "/posts", :post => { :title => "Something new in sandwiches", :detail => "Sandwich filling" }
      @post_id = @duff.path.split('/')[-1]
      @duff.get_ok("/")
      @duff.assert_select ".events .event a[href=/posts/#@post_id]", :count => 1
    end
    
    should "make one event if no comments" do
      @duff.put_via_redirect "/posts/#@post_id", :post => { :title => "New Sandwich Title", :detail => "new filling" }
      @duff.get_ok("/")
      @duff.assert_select ".events .event a[href=/posts/#@post_id]", :count => 1
    end
    
    should "make two events if comment has occurred" do
      alex = new_session_as(:alex)
      alex.post_via_redirect "/posts/#@post_id/comments", :comment => { :body => "jam tomorrow" }
      @duff.put_via_redirect "/posts/#@post_id", :post => { :title => "New Sandwich Title", :detail => "new filling" }
      @duff.get_ok("/")
      @duff.assert_select ".events .event a[href=/posts/#@post_id]", :count => 3
    end
    
    
  end
  
  should "only be able to delete a post if you're a the manager of it" do
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
      view
      get "/posts/#{post_id}"
      assert_response 404
    end
  end
  
end