class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable

  protect_from_forgery
  
  filter_parameter_logging :password
end
