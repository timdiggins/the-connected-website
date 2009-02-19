class CreateGroupPermissions < ActiveRecord::Migration
  def self.up
    create_table :group_permissions do |t|
      t.belongs_to :user
      t.belongs_to :group
      t.boolean :moderator, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :group_permissions
  end
end
