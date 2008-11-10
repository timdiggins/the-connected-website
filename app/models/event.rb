class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :detail, :polymorphic => true
  
  named_scope :sorted_by_created_at, :order => "created_at DESC" 
  named_scope :limit_to, lambda { | number | { :limit => number } }
  named_scope :without_tagging_events, :conditions => [ "detail_type <> ? AND detail_type <> ?", 'PostAddedToTagEvent', 'PostRemovedFromTagEvent']
  
  def self.create_for(detail)
    event = Event.new(:user => detail.user)
    event.detail = detail
    event.save
    detail.user.save
    event
  end
  
end
