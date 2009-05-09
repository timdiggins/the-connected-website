require "#{File.dirname(__FILE__)}/../test_helper"

class UsersTest < ActionController::IntegrationTest
  fixtures :users
  context "Individual user page" do
    should "be ok with no postings" do
      get("users/fred")
      assert_select('h2', :text => /Recently/, :count => 0)
      assert_select('h2', :text => /recent posts/, :count => 0)
    end
    
    should "be ok with postings" do
      get_ok("users/alex")
      assert_select('h2', /Recently/)
      assert_select('h2', /recent posts/)
    end
  end
  
  should "be ok for users page and the users all pages" do
    get "/users"
    assert_response :success
    assert_select "h1"
    assert_select "ul#memberList>li", :count => 1
    
    get "/users/all"
    assert_response :success
    assert_select "h1", "All Contributors"
    assert_select "ul#memberList>li", :count => 5
  end
  
  should "only be able to delete a user if you're an admin" do
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
  
end