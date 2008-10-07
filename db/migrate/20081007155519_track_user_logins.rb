class TrackUserLogins < ActiveRecord::Migration
  def self.up
    add_column :users, :login_count, :integer, :default => 0
    add_column :users, :last_login_at, :datetime
  end

  def self.down
    remove_column :users, :last_login_at
    remove_column :users, :login_count
  end
end
