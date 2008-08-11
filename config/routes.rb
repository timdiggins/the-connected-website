ActionController::Routing::Routes.draw do |map|
  
  map.temporary '/temporary', :controller => 'home', :action => 'temporary_exception'

  map.root :controller => "home"
  
end

