require "#{File.dirname(__FILE__)}/../test_helper"

class UserPageTest < ActionController::IntegrationTest
  fixtures :users

  should "user page with no postings should be as expected" do
    get("users/fred")
    assert_select('h2', :text => /Recently/, :count => 0)
    assert_select('h2', :text => /recent posts/, :count => 0)
  end

  should "user page with postings should be as expected" do
    get("users/alex")
    assert_select('h2', /Recently/)
    assert_select('h2', /recent posts/)
  end

end