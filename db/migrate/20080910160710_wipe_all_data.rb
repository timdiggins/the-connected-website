class WipeAllData < ActiveRecord::Migration
  def self.up
    Post.destroy_all
    Event.destroy_all
    Topic.destroy_all if Topic
    PostAddedToTopicEvent.destroy_all  if PostAddedToTopicEvent
    PostCategorizationEvent.destroy_all if PostCategorizationEvent
    PostRemovedFromTopicEvent.destroy_all if PostRemovedFromTopicEvent
  end

  def self.down
  end
end
