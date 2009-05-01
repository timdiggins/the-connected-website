ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

$: << File.expand_path(File.dirname(__FILE__) + "/integration/dsl")
require 'basics_dsl'
require 'republic_dsl'
require 'test_help'

#require "webrat"
#
#Webrat.configure do |config|
#  config.mode = :rails
#end


class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all

end


class ActionController::IntegrationTest

  def new_session(&block) 
    open_session do | session | 
      session.extend(BasicsDsl)
      session.extend(RepublicDsl)
      session.host!("republic.dev")
      session.instance_eval(&block) if block
      session
    end 
  end 
  
  def new_session_as(user_symbol, &block)
    session = new_session
    session.login(user_symbol)
    session.instance_eval(&block) if block
    session
  end 
  
  def logger
    Rails.logger
  end
    
end


module ActionController
  module Integration
    module Runner
      def reset!
        @integration_session = new_session
      end
    end
  end
end



