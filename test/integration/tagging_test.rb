require "#{File.dirname(__FILE__)}/../test_helper"

class TaggingTest < ActionController::IntegrationTest

  should "show no tags for the post" do
    post_id = posts(:cool_article).id
    get "/posts/#{post_id}"
    assert_select "div.tags>ul>li", :count => 0
    assert_select 'label', :text => /Add item to a tag/, :count => 0
    
    get '/tags'
    assert_select "ul#tagList>li", :count => 0
  end

  should "be able to add tags to a post" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      get "/posts/#{post_id}"
      assert_select 'label', :text => /Add item to a tag/
      
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      assert_select "div.tags>ul>li>a", "Lame Government"
      assert_select 'label', :text => /Add item to another tag/
      assert_select 'label', :text => /Add item to a tag/, :count => 0
      
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Craziness"
      assert_select "div.tags>ul>li", :count => 2
    end
  end
  
  should "handle the case of adding the same tag again" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "LAME Government"
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "CraZinesS"
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Craziness"
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Craziness"
      assert_select "div.tags>ul>li", :count => 2
      assert_select "div.tags>ul>li>a", "Lame Government"
      assert_select "div.tags>ul>li>a", "CraZinesS"
    end
  end

  
  should "be able to click a tag name and see the posts with that tag" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      click_link "Lame Government"
      assert_select "h1", /Lame Government 1 article/
      assert_select "div.posts>div.post", :count => 1
      assert_select "div.posts>div.post>div.postContent>h2>a", "Government is Bogus"
    end
  end
  
  should "see the tags of a post on the home page and the postings page" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      get '/'
      assert_select "p.tags>a", "Lame Government"
      
      get '/posts'
      assert_select "p.tags>a", "Lame Government"
    end
  end
  
  should "see the tags of a post on the tags page" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      get '/tags'
      assert_select "ul#tagList>li", :count => 1
      assert_select "ul#tagList>li>h2>a", /Lame Government.*1 article/ 
    end
  end
  
  should "see the tagging event" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      get '/'
      assert_select "div.eventBody>p.details", /duff tagged Government is Bogus.*with the tag Lame Government.*less than a minute ago/m
      assert_select "div.eventBody>p.details>a", "duff"
      assert_select "div.eventBody>p.details>a", "Government is Bogus"
      assert_select "div.eventBody>p.details>a", "Lame Government"
    end
  end
  
  should "be able to delete a tag" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      delete_via_redirect "posts/#{post_id}/tags/Lame%20Government"
      assert_select "div.tags>ul>li", :count => 0
      
      get '/tags'
      assert_select "ul#tagList>li>h2>a", /Lame Government.*0 articles/ 
    end
  end
  
  should "Be able to edit a tag" do
    new_session_as(:duff) do
      post_id = posts(:cool_article).id
      post_via_redirect "posts/#{post_id}/tags", :tag_name => "Lame Government"
      
      get 'tags/Lame%20Government'
      click_link "Add a description"
      assert_select "h1", "Edit tag: Lame Government"
      
      put_via_redirect "tags/Lame%20Government", :tag => { :name => "Super Lame Stuff", :description => "Here is the description" }
      assert_flash "Successfully updated tag"
      assert_select "h1", :text => /Lame Government/, :count => 0
      assert_select "h1", /Super Lame Stuff 1 article/
      assert_select "div#tagDescription", /Here is the description/
    end
  end
  
end

