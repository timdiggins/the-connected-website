class WipeAllData < ActiveRecord::Migration
  def self.up
    User.destroy_all
    Post.destroy_all
    Event.destroy_all
    Topic.destroy_all
    PostAddedToTopicEvent.destroy_all
    PostCategorizationEvent.destroy_all
    PostRemovedFromTopicEvent.destroy_all
  end

  def self.down
  end
end
