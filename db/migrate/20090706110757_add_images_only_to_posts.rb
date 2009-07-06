class AddImagesOnlyToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :images_only, :boolean
  end

  def self.down
    remove_column :posts, :images_only
  end
end
