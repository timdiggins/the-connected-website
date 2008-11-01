require "#{File.dirname(__FILE__)}/../test_helper"

class PostingTest < ActionController::IntegrationTest
  
  should "not be able to see the new post page if you're logged in" do
    get '/posts/new'
    assert_redirected_to '/login'
  end
  
  should "be able to see the new post page if you're logged in" do
    new_session_as(:duff) do
      get '/posts/new'
      assert_select "h1", "Create a new post"
    end
  end
  
  should "not be able to edit a post if you're the author" do
    post_id = posts(:cool_article).id
    get "/posts/#{post_id}"
    assert_link_does_not_exist "Edit post"
    
    new_session_as(:alex) do
      get "/posts/#{post_id}"
      assert_link_does_not_exist "Edit post"
    end
  end
  
  should "be able to edit a post if you're the author" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      get "/posts/#{post_id}"
      click_link "Edit post"
      
      put_via_redirect "/posts/#{post_id}", :post => { :title => "Government is Really Bogus", :detail => "Here is the body" }
      assert_select "h1.post", "Government is Really Bogus"
      assert_select "div.postBody", "Here is the body"
    end
  end
  
  should "only be able to delete a post if you're an admin" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      get "/posts/#{post_id}"
      assert_link_does_not_exist "Delete post"
    end
    
    new_session_as(:admin) do
      get '/posts'
      assert_link_exists "Government is Bogus"
      post_id = posts(:cool_article).id
      get "/posts/#{post_id}"
      assert_link_exists "Delete post"
      delete_via_redirect "/posts/#{post_id}"
      assert_link_does_not_exist "Government is Bogus"
    end
  end
    
end