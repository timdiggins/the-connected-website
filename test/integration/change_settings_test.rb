require "#{File.dirname(__FILE__)}/../test_helper"

class ChangeSettingsTest < ActionController::IntegrationTest
  fixtures :users
  PROFILE_LINK = "Your Profile"
  SETTINGS_LINK = "Your Settings"
  
  should "handle trying to change to an invalid password" do
    new_session_as(:duff) do
      put 'settings/password', { :user => { :password => '    '} }
      assert_response :ok
      assert_validation_error "Password can't be blank"
      assert_select "li.current>a", "Password"
    end
  end
  
  should "be able to change the password" do
    assert login(:duff)
    
    new_session_as(:duff) do
      put 'settings/password', { :user => { :password => 'new_password'} }
      assert_redirected_to '/users/duff'
      follow_redirect!
      assert_flash 'Saved password'
    end
    
    assert !login(:duff)
  end
  
  should "handle trying to change to an invalid username/email" do
    new_session_as(:duff) do
      put 'settings/username_email', { :user => { :login => 'duff', :email => '  '} }
      assert_response :ok
      assert_validation_error "Email can't be blank"
      assert_select "li.current>a", "User name and email"
    end
  end
  
  should "be able to change the email and username" do
    new_session_as(:duff) do
      put 'settings/username_email', { :user => { :login => 'duffer', :email => 'duffer@omelia.org'} }
      assert_redirected_to '/users/duffer'
      follow_redirect!
      click_link SETTINGS_LINK
      click_link "User name and email"
      assert_select "input#user_email[value=duffer@omelia.org]"
      assert_select "input#user_login[value=duffer]"
    end
  end
    
  should "redirect settings url to bio" do
    new_session_as(:duff) do
      get '/settings'
      assert_redirected_to '/settings/bio'
    end
    
  end
  
end
