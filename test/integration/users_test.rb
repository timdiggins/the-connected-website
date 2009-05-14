require "#{File.dirname(__FILE__)}/../test_helper"

class UsersTest < ActionController::IntegrationTest
  fixtures :users
  context "page views" do
    should "render user page with no postings" do
      get("users/fred")
      assert_select('h2', :text => /Recently/, :count => 0)
      assert_select('h2', :text => /recent posts/, :count => 0)
    end
    
    should "render user page with postings" do
      get_ok("users/alex")
      assert_select('h2', /Recently/)
      assert_select('h2', /recent posts/)
    end
    should "render users index page" do
      get "users"
      assert_response :success
      assert_select "h1"
      assert_select "ul#memberList>li", :count => 1
    end
    should "render users all page" do
      get "users/all"
      assert_response :success
      assert_select "h1", "All Contributors"
      assert_select "ul#memberList>li", :count => 6
    end
    
  end
  
  context "admin user only" do
    should "be able to delete a user" do
      user = users(:michael)
      delete_button_text = "Delete '#{user.login}' totally"
      user_page = "users/#{user.login}"
      
      new_session_as(:duff) do
        get_ok user_page
        assert_link_does_not_exist delete_button_text
        delete_via_redirect user_page
        get_ok user_page
      end
      
      new_session_as(:admin) do
        get_ok user_page
        assert_link_exists delete_button_text
        delete_via_redirect "/users/#{user.login}"
        assert_response_ok
        get user_page
        assert_response :not_found
      end
    end
    
    should "be able to trust or welcome a new user" do
      newuser = users(:newby)
      user_page = 'users/%s' % newuser
      trust_newuser_button_text = TRUST_BUTTON_TEXT % newuser
      
      new_session_as(:duff) do
        get_ok user_page
        assert_link_does_not_exist trust_newuser_button_text
        post_via_redirect trust_user_path
        assert User.find_by_login(newuser.login).is_new?
      end
      
      new_session_as(:admin) do
        get_ok user_page
        assert_link_exists trust_newuser_button_text
        post_via_redirect trust_user_path
        assert_response_ok
        assert ! User.find_by_login(newuser.login).is_new?
      end
    end
    
    should "not be able to trust or welcome an old user" do
      olduser = users(:michael)
      user_page = 'users/%s' % olduser
      trust_olduser_button_text = TRUST_BUTTON_TEXT % olduser
      
      new_session_as(:duff) do
        get_ok user_page
        assert_link_does_not_exist trust_olduser_button_text
      end
      
      new_session_as(:admin) do
        get_ok user_page
        assert_link_does_not_exist trust_olduser_button_text
      end
    end
  end
end
TRUST_BUTTON_TEXT = "Trust '%s' to post without spamming"
