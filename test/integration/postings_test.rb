require "#{File.dirname(__FILE__)}/../test_helper"

class PostingsTest < ActionController::IntegrationTest
  fixtures :all
  
  should "be able to see the post list (discussions) page" do
    get_ok '/posts'
  end
  
  should "be able to see the features list page" do
    get_ok '/posts/featured'
  end

end