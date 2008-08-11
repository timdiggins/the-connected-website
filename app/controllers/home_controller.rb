class HomeController < ApplicationController
  
  def temporary_exception
    raise "Oops!  Temporary exception testing out exception notifier on the server."
  end
  
end
