require "#{File.dirname(__FILE__)}/../test_helper"

class PostsTest < ActionController::IntegrationTest
  fixtures :all
  
  should "be able to see the post list (discussions) page" do
    get_ok '/posts'
  end
  
  should "be able to see the features list page" do
    get_ok '/posts/featured'
  end
  
  should "be able to view a post with images as an image" do
    p = post_with_images_and_text
    post_url = "/posts/#{p.id}" 
    p post_url
    get_ok post_url
    p.update_attributes(:images_only=>true)
    get_ok post_url
  end
  
end