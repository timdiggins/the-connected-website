class AddNextFetchToRssFeed < ActiveRecord::Migration
  def self.up
    add_column :rss_feeds, :error_message, :text
    add_column :rss_feeds, :next_fetch, :datetime
  end

  def self.down
    remove_column :rss_feeds, :error_message
    remove_column :rss_feeds, :next_fetch
  end
end
