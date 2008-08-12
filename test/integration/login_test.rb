require "#{File.dirname(__FILE__)}/../test_helper"

class LoginTest < ActionController::IntegrationTest
  fixtures :users

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
    
end