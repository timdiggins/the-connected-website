class EventsController < ApplicationController
  
  def index
    @events = Event.sorted_by_created_at.without_tagging_events.limit_to(5)
    
    @events = Event.sorted_by_created_at.paginate(:page => params[:page], :per_page => 15)
  end

end
