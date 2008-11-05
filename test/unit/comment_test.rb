require File.dirname(__FILE__) + '/../test_helper'

ERROR = "is invalid"
class CommentTest < ActiveSupport::TestCase

  should "validates_tiny_mce_presence_of body" do
    c = Comment.new
    assert !c.save
    assert_equal ERROR, c.errors.on(:body)
    
    c.body = '          '
    assert !c.save
    assert_equal ERROR, c.errors.on(:body)

    c.body = "  \r\n \r\n\r\n<span></span> <here>    &nbsp;  &nbsp;  &nbsp;"
    assert !c.save
    assert_equal ERROR, c.errors.on(:body)
    
    c.body = "  \r\n \r\n\r\n<span></span> Finally<here>    &nbsp;  &nbsp;  &nbsp;"
    assert c.save
  end
  
  
end
