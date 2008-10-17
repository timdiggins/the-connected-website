class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :detail, :polymorphic => true
  
  named_scope :sorted_by_created_at, lambda { { :order => "created_at DESC" }}  
  named_scope :limit_to, lambda { | number | { :limit => number } }
  
  def self.create_for(detail)
    event = Event.new(:user => detail.user)
    event.detail = detail
    event.save
    detail.user.save
    event
  end
  
  def broadcast
    # if detail.should_broadcast
    #   event_name = detail.class.to_s.sub(/Event$/, '').underscore
    #   mail = EventMailer.send("create_#{event_name}", self)
    #   EventMailer.deliver(mail) if mail.to_addrs
    # end
  end
    
end
