require "#{File.dirname(__FILE__)}/../test_helper"

class SignupTest < ActionController::IntegrationTest
  
  should "be able to signup" do
    get_ok '/signup'
    assert_select 'h1', 'Join'
    
    post '/users', { :user => { :password => "  ", :login => "freddy", :email => "freddy@codora.com" } }
    assert_validation_error "Password can't be blank"
    
    post_via_redirect '/users', { :user => { :password => "aa", :login => "freddy", :email => "freddy@codora.com" } }
    assert_response_ok
    assert_flash "Thanks for signing up!  You have been logged in."
    assert_logged_in User.find_by_login("freddy")
  end
  
    
end