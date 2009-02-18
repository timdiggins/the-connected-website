require "#{File.dirname(__FILE__)}/../test_helper"

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
    #hrefs = find_all_tag(:tag=>'a').collect { |tag| tag['href'] }.compact!
    expected_hrefs = [
      '/groups/Studio%201',
      '/groups/Studio%20Free'
    ]
    expected_hrefs.each do |href|
      assert_select "a[href='#{href}']"
    end
    end
  end
  
end