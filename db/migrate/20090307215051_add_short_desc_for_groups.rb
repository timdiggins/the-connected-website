class AddShortDescForGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :short_desc, :string
    rename_column :groups, :profile_text, :full_desc
  end

  def self.down
    remove_column :groups, :short_desc
    rename_column :groups, :full_desc, :profile_text
  end
end
