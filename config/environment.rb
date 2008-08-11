
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_republic_site_session',
    :secret => (RAILS_ENV == 'production') ? File.read(File.join(File.dirname(__FILE__), 'cookie_secret')) : 'e7bcf1669a4848dff6245564f4c31323e2877fe1ad6b069e7574a48eaed2396363a676d9288530656ff39048ccb7d9723c93874d0674f2057465a759c6d57e04'
  }
  
  config.gem "image_science", :version => '1.1.3'
end
