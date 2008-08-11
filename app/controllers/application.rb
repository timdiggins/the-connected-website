class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable
  include AuthenticatedSystem

  protect_from_forgery
  
  filter_parameter_logging :password
  before_filter :login_from_cookie
  
  def verify_authenticity_token
    unless verified_request?
      flash[:warning] = "You must login to access that part of the site."
      respond_to do |format|
        format.html { redirect_to login_url }
        format.js  { render(:update) { |page| page.redirect_to(login_url) } }
      end
    end
  end
  
end



