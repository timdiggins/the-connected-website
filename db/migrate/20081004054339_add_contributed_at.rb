class AddContributedAt < ActiveRecord::Migration
  def self.up
    add_column :users, :contributed_at, :datetime
    
    User.update_all('contributed_at = updated_at')
  end

  def self.down
    remove_column :users, :contributed_at
  end
end
