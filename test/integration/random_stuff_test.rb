require "#{File.dirname(__FILE__)}/../test_helper"

class RandomStuffTest < ActionController::IntegrationTest

  should "show our 404 page" do
    get '/nonexistent-page'
    assert_response 404
    assert_select 'h1', '404 - Page not found'
  end

end