class CreateQueuedEmails < ActiveRecord::Migration
  def self.up
    create_table :queued_emails do |t|
      t.belongs_to :event
      t.belongs_to :post
      t.timestamps
    end
  end

  def self.down
    drop_table :queued_emails
  end
end
