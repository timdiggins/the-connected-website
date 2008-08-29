class ExtendSettings < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_text, :text
    add_column :users, :home_page, :string
  end

  def self.down
    remove_column :users, :home_page
    remove_column :users, :profile_text
  end
end
