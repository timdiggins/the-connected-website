require "#{File.dirname(__FILE__)}/../test_helper"

class ChangeSettingsTest < ActionController::IntegrationTest
  fixtures :users

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
      click_link "Settings"
      click_link "User name and email"

      assert_select "input#user_email[value=duffer@omelia.org]"
      assert_select "input#user_login[value=duffer]"
    end
  end
  
  should "be able to change the bio, homepage, and location" do
    new_session_as(:duff) do
      click_link "Your public profile"
      assert_select "p", /Introduce yourself/
      assert_link_exists "add a bio"
      assert_select "p.location", false
      assert_select "div#bio", false
      assert_select "p.homepage", false

      put_via_redirect "settings", { :user => { :home_page => "omelia.org/duff", :profile_text => "Crazy anarcho-capitalist.", :location => "Willow Spring" } }
      assert_select "p.location", "Willow Spring"
      assert_select "div#bio", "Crazy anarcho-capitalist."
      assert_select "p.homepage", /duff is at home/
      assert_select 'p.homepage>a[href="http://omelia.org/duff"]', "omelia.org/duff"
      
      put_via_redirect "settings", { :user => { :home_page => "http://omelia.org/duff", :profile_text => "Crazy anarcho-capitalist.", :location => "Willow Spring" } }
      assert_select 'p.homepage>a[href="http://omelia.org/duff"]', "http://omelia.org/duff"
    end
  end
  
  should "redirect settings url to bio" do
    new_session_as(:duff) do
      get '/settings'
      assert_redirected_to '/settings/bio'
    end
    
  end

end
