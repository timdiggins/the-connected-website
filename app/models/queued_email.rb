class QueuedEmail < ActiveRecord::Base
  
  belongs_to :comment
  
  def process
    event.broadcast
    self.destroy
  end
  
  def self.create_for(comment)
    created = self.create(:comment => comment)
    created.process if Rails.env == 'development' && ENV['EVENT_EMAILS'] == 'true'
  end
  
end
