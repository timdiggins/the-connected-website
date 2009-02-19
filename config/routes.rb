ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => "sessions", :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot_password '/login/forgot_password', :controller => 'sessions', :action => 'forgot_password'
  map.reset_password 'rp/:reset_password_token', :controller => "sessions", :action => 'reset_password'
  map.admin_emails 'admin/emails', :controller => 'admin', :action => 'emails'
  map.admin_stats 'admin/stats', :controller => 'admin', :action => 'stats'
  map.info 'info/:action', :controller => 'info'
  
  map.resources :groups, :requirements => { :id => /.*/ } do |group|
    group.resources :rss_feeds
  end
  map.resources :users, :member => { :become => :post }, :collection => { :all => :get }, :requirements => { :id => /.*/ } do |user| 
    user.resources :group_permissions
  end
  map.resources :sessions
  map.resources :events
  map.resources :posts, :has_many => [ :comments ], 
  :member => { :feature => :put, :unfeature => :put, :subscribe => :post, :unsubscribe => :post }, 
  :collection => { :featured => :get }, 
  :new => { :upload => :any, :video => :any, :text => :any } \
  do | post |
    post.resources :tags, :requirements => { :id => /.*/ }
  end
  
  map.resources :tags, :requirements => { :id => /.*/ }
  map.resource  :settings, :collection => { :save_new_avatar => :put, :picture => :get, :username_email => :any, :bio => :any, :password => :any, :groups => :get}
  
  
  map.root :controller => "home"
  
  map.connect "*path", :controller => "www", :action => "unrecognized404"
end
