require "#{File.dirname(__FILE__)}/../test_helper"

ADD_LINK = '/groups/new'

class GroupsTest < ActionController::IntegrationTest
  fixtures :groups
  
  context "Unloggedin user" do
    should "be ables to see Individual group page " do
      get("groups/Studio%201")
      assert_response :success
      assert_select "h1", :text=> /Studio 1/
      assert_select "p", :text=> /Studio one is such a cool place/
    end
    
    should "be able to see  rss content for group " do
    get("groups/Studio%201")
    assert_response :success
    assert_select '.title', :text=> /Some funky thing/
  end
  
  should "be able to see recent works page" do
    get("groups/Studio%201/recent")
    assert_response :success
  end
  
end
context 'index' do
  should "have links to group" do
    get "/groups"
    assert_response :success
    assert_has_links [
      '/groups/Studio%201',
      '/groups/Studio%20Free'
    ]
  end
  
  should "have problem marker if viewed by a group admin" do
    login :duff
    assert users(:duff).can_edit?(groups(:studio3)), "precondition"
    
    assert_doesnt_have_feed_problem '/groups'        
    assert_doesnt_have_feed_problem '/groups/Studio Free'        
    
    rss_feeds(:just_fetched_feed).update_attributes(:error_message=> "yow some kind of problem")
    assert_has_feed_problem '/groups'        
    assert_has_feed_problem '/groups/Studio Free'        
    
    rss_feeds(:just_fetched_feed).update_attributes(:error_message=> '')
    assert_doesnt_have_feed_problem '/groups'        
    assert_doesnt_have_feed_problem '/groups/Studio Free'        
  end
  
  should "have problem marker if viewed by an admin" do
    login :admin
    assert !users(:admin).can_edit?(groups(:studio3)), "precondition"
    
    assert_doesnt_have_feed_problem '/groups'        
    assert_doesnt_have_feed_problem '/groups/Studio Free'        
    assert_doesnt_have_feed_problem '/'        
    
    rss_feeds(:just_fetched_feed).update_attributes(:error_message=> "yow some kind of problem")
    assert_has_feed_problem '/groups'        
    assert_has_feed_problem '/groups/Studio Free'        
    assert_has_feed_problem ''        
    
    rss_feeds(:just_fetched_feed).update_attributes(:error_message=> nil)
    assert_doesnt_have_feed_problem '/groups'        
    assert_doesnt_have_feed_problem '/groups/Studio Free'        
    assert_doesnt_have_feed_problem '/'        
  end
end

def assert_has_feed_problem path
  get path
  assert_select ".feed-problem", :count =>1
end
def assert_doesnt_have_feed_problem path
  get path
  assert_select ".feed-problem", :count =>0
  
end

should "not be able to be created by non admin" do
  login(:duff)
  get_ok '/groups'
  assert_doesnt_have_links [ADD_LINK]
  
  get ADD_LINK
  assert_response 403
  
  post "/groups", :group => { :name => "New Studio", :desc => "Studio new buttercream filling" }
  assert_response 403
end    
should "be able to be created by admin" do
  login(:admin) 
  get_ok '/groups'
  assert_has_links [ADD_LINK]
  get ADD_LINK
  assert_response :success
  post_via_redirect "/groups", :group => { :name => "New Studio", :desc => "Studio new buttercream filling" }
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
    assert_response 403
  end
end

context "Group" do
  should "be able to have feeds added/removed by a moderator " do
    login(:alex)
    get_ok 'groups/Studio%201'
    @feeds_url = '/groups/Studio%201/rss_feeds'
    assert_has_links [@feeds_url]
    get_ok @feeds_url
    assert_select 'li', :text => /.*some_new_url.*/, :count=>0
    submit_form 'new_rss_feed' do |form|
      form.rss_feed.url = 'http://some_new_url'
    end
    assert_response_ok_or_view
    
    group = Group.find_by_name('Studio 1')
    assert_equal 1, group.rss_feeds.length
    rss_feed = group.rss_feeds[0]
    assert_equal 'http://some_new_url', rss_feed.url
    delete_link = group_rss_feed_path(group, :id=>rss_feed.id)
    follow_redirect!
    assert_select "a[href=#{delete_link}]", :count=>1
    delete_via_redirect(delete_link)
    assert_response_ok_or_view
    get(@feeds_url)
    assert_select 'li', :text => /.*some_new_url.*/, :count=>0
  end
  
  should "not be able to have feeds added by non moderator" do
    login(:alex) 
    get 'groups/Studio%20Free'
    @feeds_url = 'groups/Studio%20Free/rss_feeds'
    assert_doesnt_have_links [@feeds_url]
    
    get @feeds_url
    assert_response 403
  end
end



def assert_feeds expected_feeds 
  assert_select "#feeds a",:count=>expected_feeds.length 
  expected_feeds.each do |feed|
    assert_select "#feeds a[href=#@feeds_url?url=#{feed}]",:count=>1 do |tags| 
      tags.each do |tag|
        assert(tag['onclick'].include?('POST'))
        assert(tag['onclick'].include?('delete'))
      end
    end
  end
end
def assert_remove_groups expected_remove_groups
  assert_select "#permitted-groups a", :count=>expected_remove_groups.length 
  expected_remove_groups.each do |group|
    assert_select "#permitted-groups a[href=/users/duff/group_permissions/#{group}]",:count=>1 do |tags| 
      tags.each do |tag|
        assert(tag['onclick'].include?('POST'))
        assert(tag['onclick'].include?('delete'))
      end
    end
  end
end


end