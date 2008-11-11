class AddCommentedAtToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :commented_at, :datetime
    Post.all.each do | post | 
      post.commented_at = post.updated_at
      post.save
    end
  end

  def self.down
    remove_column :posts, :commented_at
  end
end
