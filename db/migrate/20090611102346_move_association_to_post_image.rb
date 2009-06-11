class MoveAssociationToPostImage < ActiveRecord::Migration
  def self.up
    add_column :post_images, :downloaded_image_id, :integer
  end

  def self.down
    remove_column :downloaded_images, :post_image_id
  end
end
