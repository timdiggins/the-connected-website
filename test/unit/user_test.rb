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
  

  private
    def new_valid_user(options = {})
      User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire' }.merge(options))
    end

end
