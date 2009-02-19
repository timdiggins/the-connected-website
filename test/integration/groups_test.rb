require "#{File.dirname(__FILE__)}/../test_helper"

ADD_LINK = '/groups/new'

class GroupsTest < ActionController::IntegrationTest
  fixtures :groups
  
  
  context "Individual user page" do
    should "be ok " do
      get("groups/Studio%201")
      assert_response :success
      assert_select "h1", :text=> /Studio 1/
      assert_select "p", :text=> /Studio one is such a cool place/
    end
    
  end
  context 'index' do
    should "have links to group" do
      get "/groups"
      assert_response :success
      assert_select "h1"
      assert_has_links [
      '/groups/Studio%201',
      '/groups/Studio%20Free'
      ]
    end
  end
  
  should "not be able to be created by non admin" do
    login(:duff)
    get_ok '/groups'
    assert_doesnt_have_links [ADD_LINK]
    
    get ADD_LINK
    assert_response :error
    
    post "/groups", :group => { :name => "New Studio", :profile_text => "Studio new buttercream filling" }
    assert_response :error
  end    
  should "be able to be created by admin" do
    login(:admin) 
    get_ok '/groups'
    assert_has_links [ADD_LINK]
    get ADD_LINK
    assert_response :success
    post_via_redirect "/groups", :group => { :name => "New Studio", :profile_text => "Studio new buttercream filling" }
    assert_equal "/groups/New%20Studio", path
  end
  
  context "Editing a group" do
    should "be possible by moderator" do
      login(:alex)
      get_ok "groups/Studio%201"
      assert_has_links ["/groups/Studio%201/edit"]
      assert_select 'a[href=MyString]'
      get_ok "/groups/Studio%201/edit"
      submit_form do |form|
        form.group.home_page = 'http://somewhereelse'
      end
      get_ok "/groups/Studio%201"
      
      assert_select 'a[href=http://somewhereelse]'
      
    end
    
    should "not be possible be non-moderator" do
      login(:alex)
      get_ok "groups/Studio%20Free"
      assert_doesnt_have_links ["/groups/Studio%20Free/edit"]
      get "/groups/Studio%20Free/edit"
      assert_response :error
    end
  end
end