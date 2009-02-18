module RepublicDsl
  
  def assert_has_links(links)
    links.each do |link|
      assert_select "a[href='#{link}']"
    end
  end
  def assert_doesnt_have_links(links)
    links.each do |link|
      assert_select "a[href='#{link}']", :count=>0
    end
  end
  
end