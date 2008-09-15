class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :detail, :polymorphic => true
  
  named_scope :sorted_by_created_at, lambda { { :order => "created_at DESC" }}  
  named_scope :limit_to, lambda { | number | { :limit => number } }
  
  def self.create_for(detail)
    event = Event.new(:user => detail.user)
    event.detail = detail
    event.save
    detail.user.updated_at = detail.updated_at
    detail.user.save
    event
  end
  
    
end
