class EventsController < ApplicationController
  
  def index
    @events = Event.sorted_by_created
  end
  
end
