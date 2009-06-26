require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  context "a group" do
    should "should update contributed_at when new post" do
      group = Group.find(groups(:studio1).id)
      assert group.contributed_at < (Time.now- 10)
      
      group.posts.new(:title=>'some', :detail=>'some').save!
      
      group = Group.find(groups(:studio1).id)
      assert group.contributed_at > (Time.now - 10)
    end
  end 
  context "Group class" do
    should "be able to find by contributed_at" do
      groups = Group.order_by_contributed_at
      groups = groups.all # make sure we get the array!
      assert_equal 1, groups.size
      assert_equal groups(:studio1).id,groups[0].id
      
      Group.find(groups(:studio3).id).posts.new(:title=>'some', :detail=>'some').save!
      groups = Group.order_by_contributed_at
      groups = groups.all # make sure we get the array!
      assert_equal 2, groups.size
      assert_equal groups(:studio3).id,groups[0].id
    end
  end
  
  should "be able to find posts with no images" do
    TestUtil.recalculate_counters  
    posts = groups(:studio1).posts.with_no_images.all
    assert_equal 2, posts.size
    posts = groups(:studio3).posts.with_no_images.all
    assert_equal 0, posts.size
  end
  
  
end
