require "#{File.dirname(__FILE__)}/../test_helper"

class LoginTest < ActionController::IntegrationTest

  should "handle invalid login" do
    login(:duff, "wrong_password")
    assert_response_ok
    assert_flash("Invalid login or password.")
  end

  should "handle valid login" do
    login(:duff)
    assert_response_ok
    assert_select("p", {:text => "Invalid email or password.", :count => 0 })
    assert_flash("Logged in successfully")
    assert_logged_in(:duff)    
      
    alex_session = new_session_as :alex
    assert_logged_in(:duff)    
    alex_session.assert_logged_in(:alex)
  end
  
  should "be able to logout" do
    login(:duff)
    assert_response_ok
    click_link "Logout"
    assert_not_logged_in
    assert_flash "You have been logged out."
    assert_select "h1", "Login"
  end

  context "when admins only allowed to login" do 
    setup do
      AuthenticatedSystem.send :allow_anyone=, false
    end
    teardown do
      AuthenticatedSystem.send :allow_anyone=, true      
    end
  
    should "allow logins from admins" do    
      login(:admin)
      assert_response_ok
      assert_select("p", {:text => "Invalid email or password.", :count => 0 })
      assert_flash("Logged in successfully")
      assert_logged_in(:admin)    
        
    end
    
    should "handle invalid login" do
    login(:admin, "wrong_password")
    assert_response_ok
    assert_flash("Invalid login or password.")
  end

    should "not allow login from non admins" do
      
      login(:michael)
      assert_response_ok
      
      assert_not_logged_in
      newby_session = new_session_as :newby
      newby_session.assert_not_logged_in
    end
  
  end

  
end