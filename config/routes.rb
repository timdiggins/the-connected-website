ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :sessions
  map.resources :posts
  map.resources :events
  map.resource  :account, :collection => { :save_new_avatar => :put }

  map.login '/login', :controller => "sessions", :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot_password '/login/forgot_password', :controller => 'sessions', :action => 'forgot_password'
  map.reset_password 'rp/:reset_password_token', :controller => "sessions", :action => 'reset_password'

  map.root :controller => "posts"
  
end

