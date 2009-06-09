class AddContributedAtToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :contributed_at, :datetime
    Group.all.each do |group|
      latest_post = group.posts.sorted_by_created_at.first
      group.update_attributes(:contributed_at => latest_post.updated_at) unless latest_post.nil?
    end
  end

  def self.down
    add_column :groups, :contributed_at, :datetime    
  end
end
