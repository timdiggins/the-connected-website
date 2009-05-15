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
  def assert_has_current_user_links 
    assert_link_exists /a picture[?]/
  end
  def assert_doesnt_have_current_user_links   
    assert_link_does_not_exist /a picture[?]/
  end
  
  context "admin user only" do
    should "be able to delete a user" do
      user = users(:michael)
      delete_button_text = "Delete '#{user.login}' totally"
      user_page = "users/#{user.login}"
      
      duff = new_session_as(:duff)
      duff.get_ok user_page
      duff.assert_link_does_not_exist delete_button_text
      duff.delete_via_redirect user_page
      duff.get_ok user_page
      
      admin=new_session_as(:admin) 
      admin.get_ok user_page
      admin.assert_link_exists delete_button_text
      admin.delete_via_redirect "/users/#{user.login}"
      admin.assert_response_ok
      admin.get user_page
      admin.assert_response :not_found
    end
    
    
    should "be able to become a user and then become self again" do
      user = users(:michael)
      admin_user = users(:admin)
      become_button_text = "Become #{user.login}"
      user_page = "users/#{user.login}"
      
#      login(:duff) 
#      get_ok user_page
#      assert_link_does_not_exist become_button_text
#      assert_doesnt_have_current_user_links
#      post_via_redirect become_user_url(user)
#      get_ok "users/#{admin_user.login}"
#      assert_doesnt_have_current_user_links
#      
#      logout
      login(:admin) 
      get_ok user_page
      assert_link_exists become_button_text
      assert_doesnt_have_current_user_links 
      get_ok "users/#{admin_user.login}"
      assert_has_current_user_links
      
      post_via_redirect become_user_url(user)
      get_ok "users/#{admin_user.login}"
      assert_doesnt_have_current_user_links 
      get_ok "users/#{user.login}"
      assert_has_current_user_links 
      click_link 'Become self again'
      
      get_ok "users/#{admin_user.login}"
      view
      assert_has_current_user_links 
      
      get_ok "users/#{user.login}"
      assert_doesnt_have_current_user_links 
      
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
