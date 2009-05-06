ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'test_help'

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end


class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  fixtures :all
end

class ActionController::IntegrationTest
  def view
    filename = File.dirname(__FILE__) + "/../public/.integration_test_output_for_browser.html"
    flunk("There was no response to view") unless response
    File.open(filename, "w+") { | file | file.write(response.body) }
    `open #{filename}`
  end
  
  def login_as(login, password = "test")
    post sessions_url, { :login => login, :password => password }
    follow_redirect! while redirect?
    assert_select 'a', {:text=>'Login', :count=>0}, "didn't manage to login as #{login}"
  end
  
  def get_ok(path)
    get path
    assert_response_ok
  end

  # checks that the response is under 400 (ok or redirected)
  def assert_response_ok
    if @response.redirect?
      #should be ok to be a redirect of somekind... could make an option to fail if redirect
    else
      assert_response :success
    end
  end
end
