class EventsController < ApplicationController
  
  def index
    @events = Event.sorted_by_created_at
  end
  
end
