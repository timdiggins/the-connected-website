class CreateRssFeeds < ActiveRecord::Migration
  def self.up
    create_table :rss_feeds do |t|
      t.belongs_to :group
      t.string :url
      t.datetime :last_fetched 
      
      t.timestamps
    end
  end

  def self.down
    drop_table :rss_feeds
  end
end
