class QueuedEmail < ActiveRecord::Base
  
  belongs_to :comment
  
  def process
    recipients = comment.post.subscribers.map_by_email - [comment.user.email]
    recipients.each do | recipient |
      Mailer.deliver_comment_created(comment, recipient)
    end
    
    self.destroy
  end
  
  def self.create_for(comment)
    created = self.create(:comment => comment)
  end
  
end
