require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < ActiveSupport::TestCase

  should "enforce name uniqueness without case sensitivity" do
    topic = Topic.create!(:name => "Here")
    another = Topic.new(:name => "HerE")
    assert !another.valid?
  end
  
  should "handle basic relationship with post" do
    topic = Topic.create!(:name => "Cool")
    post = Post.create!(:title => "My Post", :detail => "Here it be")
    
    assert_equal([], topic.posts)
    assert_equal([], post.topics)
    
    post.topics << topic
    post.reload
    topic.reload
    assert_equal([topic], post.topics)
    assert_equal([post], topic.posts)
    
    another_post = Post.create!(:title => "My Second Post", :detail => "Here it be again")
    another_topic = Topic.create!(:name => "Really Cool")
    
    topic.posts << another_post
    another_post.reload
    topic.reload
    assert_equal([topic], post.topics)
    assert_equal([topic], another_post.topics)
    assert_equal([post, another_post], topic.posts)
    assert_equal([], another_topic.posts)
    
    post.topics << another_topic
    post.topics << another_topic
    post.topics << another_topic
    post.reload
    another_topic.reload
    assert_equal([topic, another_topic], post.topics)
    assert_equal([topic], another_post.topics)
    assert_equal([post, another_post], topic.posts)
    assert_equal([post], another_topic.posts)
    
    assert_difference("Categorization.count", -3) do
      assert_no_difference("Topic.count") do
        assert_no_difference("Post.count") do
          post.topics.delete(another_topic)
        end
      end
    end
    
    another_topic.reload
    
    assert_equal([topic], post.topics)
    assert_equal([topic], another_post.topics)
    assert_equal([post, another_post], topic.posts)
    assert_equal([], another_topic.posts)
    
    assert_difference("Categorization.count", -2) do
      assert_no_difference("Topic.count") do
        assert_no_difference("Post.count") do
          post.topics.delete(topic)
          another_post.topics.delete(topic)
        end
      end
    end
    
  end


  
end
