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
      login(:admin)
      get_ok 'users/alex'
      assert_has_links ['/users/alex/group_permissions']
      get 'users/alex/group_permissions'
      assert_response :success
      assert_add_groups [
        'Studio+1',
        'Studio+Free'
      ]
      post_via_redirect('users/alex/group_permissions?id=Studio+1')
      assert_response :success
      assert_add_groups [
        'Studio+Free'
      ]
      assert_remove_groups [
        'Studio%201',
      ]
      
      delete_via_redirect('users/alex/group_permissions/Studio%201')
      assert_response :success
      get('users/alex/group_permissions')
      assert_remove_groups []
      assert_add_groups [
        'Studio+1',
        'Studio+Free'
      ]
      
      #'form#groupmoderation', :action=>'users/alex/groups', :method=>'post'
      #      select_form "createpermatime_form" do |form|
      #        form["user[group1]"]='Apple'
      #        form.submit
      #        assert_redirected_to "/Europe/London/2009-01-02/10:30/Apple"
      #      end
      
    end
    should "not be able to be made a moderator of a group by a nonadmin" do
      login(:duff) 
      get 'users/alex'
      assert_doesnt_have_links ['users/alex/group_permissions']
      
      get 'users/alex/group_permissions'
      assert_response :error
    end
  end
  
  def assert_add_groups expected_add_groups 
   assert_select "#not-permitted-groups a",:count=>expected_add_groups.length 
    expected_add_groups.each do |group|
      assert_select "#not-permitted-groups a[href=/users/alex/group_permissions?id=#{group}]",:count=>1 do |tags| 
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
      assert_select "#permitted-groups a[href=/users/alex/group_permissions/#{group}]",:count=>1 do |tags| 
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