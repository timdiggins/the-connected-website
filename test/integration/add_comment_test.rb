require "#{File.dirname(__FILE__)}/../test_helper"

class AddCommentTest < ActionController::IntegrationTest

  should "add a comment" do
    new_session_as(:alex) do
      post_via_redirect "/posts/#{posts(:cool_article).id}/comments", :comment => { :body => "YoYo" }
      assert_select("div#comments>div.comment>div.postContent", :count => 1)
      assert_select("div#comments>div.comment>div.postContent", /YoYo/)
      
      post_via_redirect "/posts/#{posts(:cool_article).id}/comments", :comment => { :body => "HereHere" }
      assert_select("div#comments>div.comment>div.postContent", :count => 2)
    end
  end

end

