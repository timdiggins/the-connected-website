class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :detail, :polymorphic => true
  
  def self.create_for(detail)
    event = Event.new(:user => detail.user)
    event.detail = detail
    event.save
    event
  end
  
    
end
