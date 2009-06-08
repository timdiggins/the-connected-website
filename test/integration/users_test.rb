require "#{File.dirname(__FILE__)}/../test_helper"

class UsersTest < ActionController::IntegrationTest
  fixtures :users
  context "Individual user" do
    should "be viewable with no postings" do
      get("users/tim")
      assert_select('h2', :text => /Recently/, :count => 0)
    end
    
    should "be viewable with postings" do
      get("users/alex")
      assert_select('h2', /Recently/)
    end
    
    should "be able to be made a moderator of a group by an admin" do
      login(:admin)
      get_ok 'users/tim'
      assert_has_links ['/users/tim/group_permissions']
      get 'users/tim/group_permissions'
      assert_response :success
      assert_add_groups [
        'Studio+1',
        'Studio+Free'
      ]
      post_via_redirect('users/tim/group_permissions?id=Studio+1')
      assert_response :success
      assert_add_groups [
        'Studio+Free'
      ]
      assert_remove_groups [
        'Studio%201',
      ]
      
      delete_via_redirect('users/tim/group_permissions/Studio%201')
      assert_response :success
      get('users/tim/group_permissions')
      assert_remove_groups []
      assert_add_groups [
        'Studio+1',
        'Studio+Free'
      ]      
    end
    
    should "not be able to be made a moderator of a group by a nonadmin" do
      login(:duff) 
      get 'users/duff'
      assert_doesnt_have_links ['users/duff/group_permissions']
      
      get 'users/duff/group_permissions'
      assert_response 403
    end
  end
  
  def assert_add_groups expected_add_groups 
   assert_select "#not-permitted-groups a",:count=>expected_add_groups.length 
    expected_add_groups.each do |group|
      assert_select "#not-permitted-groups a[href=/users/tim/group_permissions?id=#{group}]",:count=>1 do |tags| 
        tags.each do |tag|
          assert(tag['onclick'].include?('POST'))
          assert(!tag['onclick'].include?('delete'))
        end
      end
    end
  end
  def assert_remove_groups expected_remove_groups
    assert_select "#permitted-groups a", :count=>expected_remove_groups.length 
    expected_remove_groups.each do |group|
      assert_select "#permitted-groups a[href=/users/tim/group_permissions/#{group}]",:count=>1 do |tags| 
        tags.each do |tag|
          assert(tag['onclick'].include?('POST'))
          assert(tag['onclick'].include?('delete'))
        end
      end
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