require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  should "should updated_at when new post" do
    group = Group.find(groups(:studio1).id)
    assert group.updated_at < (Time.now+ 10)
    
    group.posts.new(:title=>'some', :detail=>'some').save!
    
    group = Group.find(groups(:studio1).id)
    assert group.updated_at > (Time.now + 10)
  end
  
  context "Group class" do
    should "be able to find by contributed_at" do
      groups = Group.order_by_contributed_at
      groups = groups.all # make sure we get the array!
      assert_equal 1, groups.size
      assert_equal group(:studio1).id,groups[0]
      
      Group.find(groups(:studio3).id).posts.new(:title=>'some', :detail=>'some').save!
          groups = Group.order_by_contributed_at
      groups = groups.all # make sure we get the array!
      assert_equal 2, groups.size
      assert_equal group(:studio3).id,groups[0]
    end
  end
  
end
