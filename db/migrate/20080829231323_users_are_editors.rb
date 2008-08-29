class UsersAreEditors < ActiveRecord::Migration
  def self.up
    add_column :users, :editor, :boolean, :default => false
    add_column :posts, :featured, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :featured
    remove_column :users, :editor
  end
end
