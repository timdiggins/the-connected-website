require "#{File.dirname(__FILE__)}/../test_helper"

class CommentTest < ActionController::IntegrationTest
  fixtures :posts, :comments
  DELETE_COMMENT_TEXT = "Delete"
  EDIT_COMMENT_TEXT = "Edit"
  
  def testpost
    "/posts/#{posts(:cool_article).id}"
  end
  def expect_able_to_comment session, commentbody
    session.post_via_redirect "#{testpost}/comments", :comment => { :body => commentbody }
    session.assert_response_ok
    @expected_commentcount += 1
    session.assert_select("div#comments>div.comment>div.postContent", :count => @expected_commentcount)
    session.assert_select("div#comments>div.comment>div.postContent", /#{commentbody}/)
  end
  
  def expect_not_able_to_comment session, commentbody
    session.post_via_redirect "#{testpost}/comments", :comment => { :body => commentbody }
    session.get "#{testpost}"
    session.assert_select("div#comments>div.comment>div.postContent", :count => @expected_commentcount)
    session.assert_select("div#comments>div.comment>div.postContent", :text=> /#{commentbody}/, :count=>0)
  end
  
  should "be able to add a comment twice if regular user" do
    session = new_session_as(:alex)
    @expected_commentcount = 0
    expect_able_to_comment session, "comment no1 from alex" 
    expect_able_to_comment session, "comment no2 from alex" 
  end
  
  should "not be able to add a comment twice if new user" do
    session = new_session_as(:newby)
    @expected_commentcount = 0
    expect_able_to_comment session, "comment no1 from newby" 
    expect_not_able_to_comment session, "comment no2 from newby" 
  end
  
  should "give validation mentioning when attempting to add blank comment" do
    alex = new_session_as(:alex) 
    alex.post "#{testpost}/comments", :comment => { :body => "" }
    alex.assert_response_ok
    alex.assert_select("div#comments>div.comment>div.postContent", :count => 0)
    alex.assert_flash /empty/
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
