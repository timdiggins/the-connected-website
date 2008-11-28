require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase

  should "enforce name uniqueness without case sensitivity" do
    tag = Tag.create!(:name => "Here")
    another = Tag.new(:name => "HerE")
    assert !another.valid?
  end
  
  should "handle basic relationship with post" do
    tag = Tag.create!(:name => "Cool")
    post = Post.create!(:title => "My Post", :detail => "Here it be")
    
    assert_equal([], tag.posts)
    assert_equal([], post.tags)
    
    post.tags << tag
    post.reload
    tag.reload
    assert_equal([tag], post.tags)
    assert_equal([post], tag.posts)
    
    another_post = Post.create!(:title => "My Second Post", :detail => "Here it be again")
    another_tag = Tag.create!(:name => "Really Cool")
    
    tag.posts << another_post
    another_post.reload
    tag.reload
    assert_equal([tag], post.tags)
    assert_equal([tag], another_post.tags)
    assert_equal([post, another_post], tag.posts)
    assert_equal([], another_tag.posts)
    
    post.tags << another_tag
    post.tags << another_tag
    post.tags << another_tag
    post.reload
    another_tag.reload
    assert_equal([tag, another_tag], post.tags)
    assert_equal([tag], another_post.tags)
    assert_equal([post, another_post], tag.posts)
    assert_equal([post], another_tag.posts)
    
    assert_difference("Categorization.count", -3) do
      assert_no_difference("Tag.count") do
        assert_no_difference("Post.count") do
          post.tags.delete(another_tag)
        end
      end
    end
    
    another_tag.reload
    
    assert_equal([tag], post.tags)
    assert_equal([tag], another_post.tags)
    assert_equal([post, another_post], tag.posts)
    assert_equal([], another_tag.posts)
    
    assert_difference("Categorization.count", -2) do
      assert_no_difference("Tag.count") do
        assert_no_difference("Post.count") do
          post.tags.delete(tag)
          another_post.tags.delete(tag)
        end
      end
    end
    
  end

  should "raise RecordNotFound if there's no tag with the name" do
    assert_raises(ActiveRecord::RecordNotFound) { Tag.find_by_name!("CoolStuff") }
    
    t = Tag.create!(:name => "CoolStuff")
    assert_nothing_raised {  
      assert_equal(t, Tag.find_by_name!("CoolStuff"))
    }
  end
  
  should "be able to count all" do
    assert_equal 4, Tag.count
  end

  should "be able to get all (for tag cloud)" do
    tags = Tag.all_with_count
    assert_equal 4, tags.size
    assert_equal ['bogus','boring','interesting','penguin'], tags.collect{|tag| tag.name }
    assert_equal [2, 1, 1, 1], tags.collect{|tag| tag.count }
  end
end
