ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :sessions
  map.resources :posts, :has_many => :comments
  map.resources :events
  map.resource  :settings, :collection => { :save_new_avatar => :put }

  map.login '/login', :controller => "sessions", :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot_password '/login/forgot_password', :controller => 'sessions', :action => 'forgot_password'
  map.reset_password 'rp/:reset_password_token', :controller => "sessions", :action => 'reset_password'
  
  map.info 'info/:action', :controller => 'info'
  
  map.root :controller => "posts"
  
end

