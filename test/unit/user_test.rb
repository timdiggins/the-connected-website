require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  should "require password" do
    user = new_valid_user(:login => 'my_login', :email => 'me@example.com')
    assert(user.send(:password_required?))
    
    user.password = "wow"
    assert(user.save)
    
    user = User.find(user.id)
    assert(!user.send(:password_required?))
    
    user.password_required = true
    assert(user.send(:password_required?))
    
    user = User.find(user.id)
    user.password = "   "
    assert(!user.send(:password_required?))
    
    user.password = "Something"
    assert(user.send(:password_required?))
  end
  
  should "create user" do
    assert_difference 'User.count' do
      user = new_valid_user
      assert user.save
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end
  
  should "reset password" do
    users(:duff).update_attributes(:password => 'new password')
    assert_equal users(:duff), User.authenticate('duff', 'new password')
  end
  
  should "not rehash password" do
    users(:duff).update_attributes(:login => 'duff2')
    assert_equal users(:duff), User.authenticate('duff2', 'test')
  end
  
  should "authenticate user" do
    assert_equal users(:duff), User.authenticate('duff', 'test')
  end
  
  should "set remember token" do
    users(:duff).remember_me
    assert_not_nil users(:duff).remember_token
    assert_not_nil users(:duff).remember_token_expires_at
  end
  
  should "unset remember token" do
    users(:duff).remember_me
    assert_not_nil users(:duff).remember_token
    users(:duff).forget_me
    assert_nil users(:duff).remember_token
  end
  
  should "add apostrophe s appropriately" do
    user = User.new(:login => "Fred")
    assert_equal("Fred's", user.possessive_to_s)
    
    user.login = "login_ending_with_s"
    assert_equal("login_ending_with_s'", user.possessive_to_s)
  end
  
  should "raise RecordNotFound if there's no user with the login" do
    assert_raises(ActiveRecord::RecordNotFound) { User.find_by_login!("CoolGuy") }
    
    t = new_valid_user(:login => "CoolGuy")
    t.save!
    assert_nothing_raised {  
      assert_equal(t, User.find_by_login!("CoolGuy"))
    }
  end
  
  context "a temporary user" do
    setup do 
      new_valid_user(:login => "TemporaryUser").save!
    end
    
    should "be destroyed if has no dependencies" do
      test_user.destroy()
      assert_raises(ActiveRecord::RecordNotFound) { test_user! }
    end
    
    context "with comments" do
      setup do
        create_comment_for test_user
      end
      should "not be destroyed" do
        assert test_user.has_creations
        assert_raises(RuntimeError) { test_user.destroy }
      end
    end
    
    context "with events" do
      setup do
        create_event_for test_user
      end
      should "not be destroyed" do
        assert test_user.has_creations
        assert_raises(RuntimeError) { test_user.destroy }
      end
    end
    context "with events and comments" do
      setup do
        create_event_for test_user
        create_comment_for test_user
      end
      
      should "not be destroyed" do
        assert test_user.has_creations
        assert_raises(RuntimeError) { test_user.destroy }
      end
      should " be destroyed after deletion of dependencies" do
        assert test_user.has_creations
        test_user.destroy_creations
        assert_nothing_raised { test_user.destroy }
      end
    end
  end
  
 should "be able to find group permissions" do
   assert_equal 1, users(:duff).group_permissions.length
   assert_equal 1, users(:alex).group_permissions.length
   assert_equal 0, users(:fred).group_permissions.length
   assert !users(:duff).can_edit?(groups(:studio1))
   assert users(:alex).can_edit?(groups(:studio1))
   assert !users(:alex).can_edit?(groups(:studio3))
   assert users(:duff).can_edit?(groups(:studio3))
   assert !users(:fred).can_edit?(groups(:studio1))
   assert !users(:fred).can_edit?(groups(:studio3))
 end
  
  private
  def test_user()
    User.find_by_login("TemporaryUser")
  end
  def test_user!()
    User.find_by_login!("TemporaryUser")
  end
#  def create_post_for u
#    Post.new(:user=>u, :title=>"sometitle",:detail=>"something").save! 
#  end
  def create_comment_for u
    Comment.new(:post=> Post.all[0], :user=>u,:body=>"something").save!
  end
  def create_event_for u
    tag_name ="my lovely tag"
    tag =Tag.find_by_name(tag_name) || Tag.new(:name => tag_name)
    Event.create_for(PostAddedToTagEvent.new(:user=>u, :post=>Post.all[0], :tag=>tag)).save!
  end
  
  def new_valid_user(options = {})
    User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire' }.merge(options))
  end

end
