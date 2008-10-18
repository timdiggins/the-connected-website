class QueuedEmail < ActiveRecord::Base
  
  belongs_to :comment
  
  def process
    mail = Mailer.create_comment_created(comment)
    Mailer.deliver(mail) if mail.to_addrs
    self.destroy
  end
  
  def self.create_for(comment)
    created = self.create(:comment => comment)
    created.process if Rails.env == 'development'# && ENV['EVENT_EMAILS'] == 'true'
  end
  
end
