class QueuedEmailsLessGeneric < ActiveRecord::Migration
  def self.up
    remove_column :queued_emails, :post_id
    remove_column :queued_emails, :event_id
    add_column :queued_emails, :comment_id, :integer
  end

  def self.down
    remove_column :queued_emails, :comment_id
    add_column :queued_emails, :event_id, :integer
    add_column :queued_emails, :post_id, :integer
  end
end
