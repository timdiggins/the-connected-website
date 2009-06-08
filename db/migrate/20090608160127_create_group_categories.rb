class CreateGroupCategories < ActiveRecord::Migration
  def self.up
    create_table :group_categories do |t|
      t.string :name
      t.timestamps
    end
    
    add_column :groups, :group_category_id, :integer
  end

  def self.down
    drop_table :group_categories
    remove_column :groups, :group_category_id
  end
end
