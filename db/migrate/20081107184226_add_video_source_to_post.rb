class AddVideoSourceToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :video, :text
  end

  def self.down
    remove_column :posts, :video
  end
end
