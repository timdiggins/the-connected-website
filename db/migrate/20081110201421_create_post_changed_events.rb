class CreatePostChangedEvents < ActiveRecord::Migration
  def self.up
    create_table :post_changed_events do |t|
      t.belongs_to :user
      t.belongs_to :post
      t.timestamps
    end
  end

  def self.down
    drop_table :post_changed_events
  end
end
