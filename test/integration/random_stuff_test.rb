require "#{File.dirname(__FILE__)}/../test_helper"

class RandomStuffTest < ActionController::IntegrationTest
  
  should "show our 404 page" do
    get '/nonexistent-page'
    assert_response 404
    assert_select 'h1', '404 - Page not found'
  end
  
  context "homepage" do
    should "work unlogged in" do
      get_ok "/"
      assert_has_link_to_manage_rss_feeds false
    end
    
    should "work as admin " do
      login :admin
      get_ok '/'
      assert_has_link_to_manage_rss_feeds true
    end
    
    should "work as other non_moderator user" do
      nonmod = :fred
      login nonmod
      user = users(nonmod)
      Group.all.each { |group| assert(!user.can_edit?(group), "precondition - can't moderate")}
      get_ok '/'
      assert_has_link_to_manage_rss_feeds false      
    end
    
    should "work as group moderator" do
       mod = :duff
       login mod 
      assert users(mod).can_edit?(groups(:studio3)), "precondition"
      get_ok '/'
      assert_has_link_to_manage_rss_feeds false
    end
    
  end
  
  def assert_has_link_to_manage_rss_feeds has_link
    assert_select "a[href=/rss_feeds]", :count=> (has_link ? 1 : 0)
  end
  
end