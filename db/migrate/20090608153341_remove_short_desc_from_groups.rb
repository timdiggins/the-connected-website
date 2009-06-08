class RemoveShortDescFromGroups < ActiveRecord::Migration
  def self.up
    rename_column :groups, :full_desc, :desc
    remove_column :groups, :short_desc
  end

  def self.down
    rename_column :groups, :desc, :full_desc 
    add_column :groups, :short_desc, :string    
  end
end
