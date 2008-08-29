class CreatePostCategorizationEvents < ActiveRecord::Migration
  def self.up
    Event.destroy_all("detail_type = 'PostAddedToTopicEvent'")
    
    drop_table :post_added_to_topic_events

    create_table :post_categorization_events do |t|
      t.belongs_to :user
      t.belongs_to :topic
      t.belongs_to :post
      t.string :type
      t.timestamps
    end
  end

  def self.down
    create_table "post_added_to_topic_events", :force => true do |t|
      t.integer  "user_id"
      t.integer  "topic_id"
      t.integer  "post_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    drop_table :post_categorization_events
  end
end
