class AddIsNewToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_new, :boolean, :default=> true
    User.update_all('is_new = false')
  end

  def self.down
    remove_column :users, :is_new
  end
end
