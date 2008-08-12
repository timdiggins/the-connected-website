class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :detail, :polymorphic => true
  
  named_scope :sorted_by_created_at, lambda { { :order => "created_at DESC" }}  
  
  def self.create_for(detail)
    event = Event.new(:user => detail.user)
    event.detail = detail
    event.save
    event
  end
  
    
end
