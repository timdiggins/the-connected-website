require "#{File.dirname(__FILE__)}/../test_helper"

class CommentTest < ActionController::IntegrationTest
  fixtures :posts, :comments
  DELETE_COMMENT_TEXT = "Delete"
  EDIT_COMMENT_TEXT = "Edit"
  
  should "add a comment" do
    new_session_as(:alex) do
      post_via_redirect "/posts/#{posts(:cool_article).id}/comments", :comment => { :body => "YoYo" }
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent", :count => 1)
      assert_select("div#comments>div.comment>div.postContent", /YoYo/)
      
      post_via_redirect "/posts/#{posts(:cool_article).id}/comments", :comment => { :body => "HereHere" }
      assert_select("div#comments>div.comment>div.postContent", :count => 2)
    end
  end
  
  should "give validation mentioning when attempting to add blank comment" do
    new_session_as(:alex) do
      post "/posts/#{posts(:cool_article).id}/comments", :comment => { :body => "" }
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent", :count => 0)
      assert_flash /empty/
    end
  end
  
  should "have comment preexisting" do
    new_session_as(:fred) do
      get "/posts/#{posts(:alex_interesting_article).id}"
      assert_response :success
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent", :count => 1)
      assert_select("div#comments>div.comment>div.postContent", /dude/) 
    end
  end
  
  should "be able to delete a comment only if you are an admin" do
    blk = Proc.new do
      get "/posts/#{posts(:alex_interesting_article).id}"
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent",  :count=>1) {
        assert_link_does_not_exist DELETE_COMMENT_TEXT
      }
    end
    new_session_as(:duff,  &blk)
    new_session_as(:alex,  &blk) 
    new_session_as(:admin) do
      get "/posts/#{posts(:alex_interesting_article).id}"
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent", :count=>1) {
        r = click_link DELETE_COMMENT_TEXT, :delete
        assert_response_ok
      }
      get "/posts/#{posts(:alex_interesting_article).id}"
      assert_select("div#comments>div.comment>div.postContent",false)
    end
  end
  
  should "be able to edit a comment only if you made it" do
    new_session_as(:alex) do
      get "/posts/#{posts(:alex_interesting_article).id}"
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent", :count=>1) {
        assert_link_does_not_exist EDIT_COMMENT_TEXT
      }
    end
    new_session_as(:duff) do
      get "/posts/#{posts(:alex_interesting_article).id}"
      assert_response_ok
      assert_select("div#comments>div.comment>div.postContent",  :count=>1) {
        click_link_by_attr :text=>EDIT_COMMENT_TEXT, :without_redirect=>true
        assert_template  'comments/edit'
      }
      get "/posts/#{posts(:alex_interesting_article).id}/#{comments(:duffs_comment_on_alex_interesting_article).id}"
      
    end
  end
  
end
