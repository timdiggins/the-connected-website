class AddCaptionToPostImage < ActiveRecord::Migration
  def self.up
    add_column :post_images, :caption, :text
  end

  def self.down
    remove_column :post_images, :caption
  end
end
