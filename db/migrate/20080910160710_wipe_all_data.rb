class WipeAllData < ActiveRecord::Migration
  def self.up
    safely { Post.destroy_all }
    safely { Event.destroy_all }
    safely { ::Topic.destroy_all }
    safely { PostAddedToTopicEvent.destroy_all }
    safely { PostCategorizationEvent.destroy_all }
    safely { PostRemovedFromTopicEvent.destroy_all }
  end

  def self.down
  end
  
  def safely
    yield
  rescue NoMethodError
  end
end
