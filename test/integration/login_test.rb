require "#{File.dirname(__FILE__)}/../test_helper"

class LoginTest < ActionController::IntegrationTest

  should "handle invalid login" do
    login(:duff, "wrong_password")
    assert_flash("Invalid login or password.")
  end

  should "handle valid login" do
    login(:duff)
    assert_select("p", {:text => "Invalid email or password.", :count => 0 })
    assert_flash("Logged in successfully")
    assert_logged_in(:duff)    
      
    alex_session = new_session_as :alex
    assert_logged_in(:duff)    
    alex_session.assert_logged_in(:alex)
  end
  
  should "be able to signup" do
    get '/signup'
    assert_select 'h1', 'Join'
    
    post '/users', { :user => { :password => "  ", :login => "freddy", :email => "freddy@codora.com" } }
    assert_validation_error "Password can't be blank"
    
    post_via_redirect '/users', { :user => { :password => "aa", :login => "freddy", :email => "freddy@codora.com" } }
    assert_flash "Thanks for signing up!  You have been logged in."
    assert_logged_in User.find_by_login("freddy")
  end
  
    
end