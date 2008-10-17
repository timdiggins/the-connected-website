class QueuedEmail < ActiveRecord::Base
  
  belongs_to :event
  belongs_to :post
  
  def process
    event.broadcast
    self.destroy
  end
  
  def self.create_for(post, event)
    return if post.subscribers.empty?
    created = self.create(:event => event)
    created.process if Rails.env == 'development' && ENV['EVENT_EMAILS'] == 'true'
  end
  
end
