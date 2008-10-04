class TopicsToTags < ActiveRecord::Migration
  def self.up
    rename_table :topics, :tags
    rename_column :categorizations, :topic_id, :tag_id
    rename_column :post_categorization_events, :topic_id, :tag_id
    
    Event.update_all("detail_type = 'PostRemovedFromTagEvent'", "detail_type = 'PostRemovedFromTopicEvent'")
    Event.update_all("detail_type = 'PostAddedToTagEvent'", "detail_type = 'PostAddedToTopicEvent'")
  end

  def self.down
    Event.update_all("detail_type = 'PostRemovedFromTopicEvent'", "detail_type = 'PostRemovedFromTagEvent'")
    Event.update_all("detail_type = 'PostAddedToTopicEvent'", "detail_type = 'PostAddedToTagEvent'")

    rename_column :post_categorization_events, :tag_id, :topic_id
    rename_column :categorizations, :tag_id, :topic_id
    rename_table :tags, :topics
  end
end
