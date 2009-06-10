class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable
  include AuthenticatedSystem
  include Exceptions
  
  protect_from_forgery
  
  filter_parameter_logging :password
  before_filter :login_from_cookie
  before_filter :check_for_admin_feed_problems
  rescue_from 'Exceptions::PermissionDenied' do |e| http_status_code(:forbidden, e) end
  
  # Returns a HTTP status code, with a nice error page
  def http_status_code(status, exception)
    # store the exception so its message can be used in the view
    @exception = exception
    
    # Only add the error page to the status code if the request-format was HTML
    respond_to do |format|
      format.html { render :template => "errors/status_#{status.to_s}", :status => status }
      format.any  { head status } # only return the status code
    end
  end
  
  
  protected 
  def check_for_admin_feed_problems
    return unless logged_in_as_admin?
    @admin_feeds_class = "admin"
    RssFeed.all.each do |rss_feed|
      if rss_feed.has_problem?
        @admin_feeds_class= "site-admin feed-problem"
        return true
      end
    end
    return true
  end

  private
    def verify_authenticity_token
      unless verified_request?
        flash[:warning] = "You must login to access that part of the site."
        respond_to do |format|
          format.html { redirect_to login_url }
          format.js  { render(:update) { |page| page.redirect_to(login_url) } }
        end
      end
    end
    
    def self.tiny_mce_options
      { :theme => 'advanced',
        :theme_advanced_toolbar_location => "top",
        :theme_advanced_toolbar_align => "left",
        :editor_selector => 'mceEditor',
        :theme_advanced_buttons1 => %w{ bold italic strikethrough separator bullist numlist separator indent outdent separator image link unlink},
        :theme_advanced_buttons2 =>  "",
        :theme_advanced_buttons3 =>  ""
      } 
    end
  
end
