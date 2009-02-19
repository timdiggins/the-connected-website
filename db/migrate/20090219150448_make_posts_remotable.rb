class MakePostsRemotable < ActiveRecord::Migration
  def self.up
    add_column :posts, :remote_url, :string
    add_column :posts, :group_id, :integer 
  end

  def self.down
    remove_column :posts, :remote_url
    remove_column :posts, :group_id
  end
end
