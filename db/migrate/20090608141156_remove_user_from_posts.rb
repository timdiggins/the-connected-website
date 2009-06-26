class RemoveUserFromPosts < ActiveRecord::Migration
  def self.up
    remove_column :posts, :user_id
  end
  
  def self.down
    add_column :posts, :user_id, :integer  
  end
end
