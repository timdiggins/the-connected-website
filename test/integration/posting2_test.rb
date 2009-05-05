require "#{File.dirname(__FILE__)}/../webrat_test_helper"

class PostingTest < ActionController::IntegrationTest
  
  context "Existing user" do
    should "be able to upload a pdf" do
      login_as(:duff)
      post_via_redirect "/posts", :post => { 
        :title => "Something new in filing", :detail => "Filing filling", :specifying_upload => true,
        :post_attachment=>ActionController::TestUploadedFile.new(Test::Unit::TestCase.fixture_path + '/files/sample.pdf', 'application/pdf') }
      @post_id = path.split('/')[-1]
      get_ok("/")
      assert_select ".events .event a[href=/posts/#@post_id]", :count => 1
      get("/posts/#@post_id")
    end
    
    should "be able to upload a pdf and change description" do
      login_as(:duff)
      post_via_redirect "/posts", :post => { 
        :title => "Something new in filing", :detail => "Filing filling", :specifying_upload => true,
        :post_attachment=>ActionController::TestUploadedFile.new(Test::Unit::TestCase.fixture_path + '/files/sample.pdf', 'application/pdf') }
      @post_id = path.split('/')[-1]
      get_ok("/posts/#@post_id")
      
      click_link 'Edit post'
      fill_in 'post_detail', :with => "Some other body"
      click_button 
      assert_response 200
      assert_select "div.fileBody", /Some other body.*/
      
      click_link 'Edit post'
      fill_in 'post_title',  :with => "Some other title"
      click_button 
      assert_response 200
      view
      assert_select "h1.post", "Some other title"
      assert_select "div.fileBody", /Some other body.*/
    end
    
  end
end