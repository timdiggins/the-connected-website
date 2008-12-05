module BasicsDsl
  
  def view
    filename = File.dirname(__FILE__) + "/../../../public/.integration_test_output_for_browser.html"
    flunk("There was no response to view") unless response
    File.open(filename, "w+") { | file | file.write(response.body) }
    `open #{filename}`
  end
  
  def login(login, password = "test")
    post sessions_url, { :login => login, :password => password }
    result = response.redirect_url == root_url
    follow_redirect! while redirect?
    result
  end
  
  # performs a get request and checks that the response is under 400 (ok or redirected)
  def get_ok(path, parameters = nil, headers = nil)
    r = get(path, parameters, headers)
    assert_response_ok
    r
  end
  
  # checks that the response is under 400 (ok or redirected)
  def assert_response_ok
    if @response.redirect?
      #should be ok to be a redirect of somekind... could make an option to fail if redirect
    else
      assert_response :success
    end
  end
  
  def logout
    get_via_redirect logout_url
  end
  
  def click_link(link_text, method = :get)
    assert_select("a", link_text, "Trying to click a link named '#{link_text}' that did not exist") do | links |
      address = links.first.attributes['href']
      return get_via_redirect(address) if method == :get
      return post_via_redirect(address) if method == :post
      return delete_via_redirect(address) if method == :delete
    end
  end
  
  def click_link_by_attr(options={})
    method = options[:method] || :get
    selector = "a"
    if options[:id]
      selector << ('#%s' % options[:id])
    elsif options[:class]
      selector << ('.%s' % options[:class])
    end
    select_options = {:count=>1}
    select_options[:text] = options[:text] 

    assert_select(selector, select_options, "Trying to click a link '#{selector}' #{"with text ''" % options[:text] if options[:text]} that did not exist") do | links |
      address = links.first.attributes['href']
      if options[:without_redirect]
        return get(address) if method == :get
        return post(address) if method == :post
        return delete(address) if method == :delete
      else
        return get_via_redirect(address) if method == :get
        return post_via_redirect(address) if method == :post
        return delete_via_redirect(address) if method == :delete
      end  
    end
  end
  
  def assert_link_exists(link_text)
    assert_select("a", link_text, "Expected the link '#{link_text}' to exist.")  
  end
  
  def assert_link_does_not_exist(link_text)
    assert_select("a", { :text => link_text, :count => 0 }, "Did not expect the link '#{link_text}' to exist.")  
  end
  
  def assert_flash(expected_flash_value)
    assert_select("div#flash>p", expected_flash_value, "Expected the flash to be '#{expected_flash_value}'")
  end
  
  def assert_validation_error(error_text)
    assert_select("div.errorExplanation ul>li", error_text, "Expected there to be a validation error of '#{error_text}'") 
  end
  
  def assert_logged_in(user_or_user_symbol)
    user = user_or_user_symbol.kind_of?(User) ? user_or_user_symbol : users(user_or_user_symbol) 
    assert_equal(user.id, session[:user], "#{user} should have been logged in.")
  end
  
  def assert_not_logged_in
    assert_nil(session[:user], "No user should be logged in.")
  end
  
  def get_with_basic_authentication(path, user_symbol)
    get path, {}, { :authorization => "Basic #{Base64.encode64("#{users(user_symbol).api_authentication_token}:X")}" }
    end
    
    def post_with_basic_authentication(path, parameters, user_symbol)
      post path, parameters, { :authorization => "Basic #{Base64.encode64("#{users(user_symbol).api_authentication_token}:X")}" }
      end
      
      def delete_with_basic_authentication(path, user_symbol)
        delete path, {}, { :authorization => "Basic #{Base64.encode64("#{users(user_symbol).api_authentication_token}:X")}" }
        end
        
      end