require "#{File.dirname(__FILE__)}/../test_helper"

class UsersTest < ActionController::IntegrationTest
  fixtures :users
  context "Individual user" do
    should "be viewable with no postings" do
      get("users/fred")
      assert_select('h2', :text => /Recently/, :count => 0)
      assert_select('h2', :text => /recent posts/, :count => 0)
    end
    
    should "be viewable with postings" do
      get("users/alex")
      assert_select('h2', /Recently/)
      assert_select('h2', /recent posts/)
    end
    
    should "be able to be made a moderator of a group by an admin" do
      flunk 'not yet'
    end
    should "not be able to be made a moderator of a group by a nonadmin" do
      flunk 'not yet'      
    end
  end
  
  should "be ok for users page and the users/all pages" do
    get "/users"
    assert_response :success
    assert_select "h1"
    assert_select "ul#memberList>li", :count => 1
    
    get "/users/all"
    assert_response :success
    assert_select "h1", "All Contributors"
    assert_select "ul#memberList>li", :count => 5
  end
  
end