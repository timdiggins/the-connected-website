require "#{File.dirname(__FILE__)}/../test_helper"

class UserPageTest < ActionController::IntegrationTest
  fixtures :users

  should "user page with no postings should be as expected" do
    get("users/duff")
    assert_has_selector_containing_text("h2", /.*Recently.*/, {:exactly => 0 })
    assert_has_selector_containing_text("h2", /.*recent posts.*/, {:exactly => 0 })
  end

  should "user page with postings should be as expected" do
    print "user page with postings should be as expected"
    get("users/alex")
    assert_has_selector_containing_text("h2", /.*Recently.*/, {:exactly => 1 })
    assert_has_selector_containing_text("h2", /.*recent posts.*/, {:exactly => 1 })
  end

  def assert_has_selector_containing_text(selector, textMatcher, count)
    puts selector
    found = 0
    elems = css_select(selector)
      elems.each { |elem |
      puts "aha",  elem.class, elem
      if elem.to_s =~ textMatcher
        puts "elem matches"
        found += 1
      end
    }
    puts found
    if count.has_key?(:exactly)
      assert_equal count[:exactly], found
    end
    
  end

end