class AddHeightWidthToPostImages < ActiveRecord::Migration
  def self.up
    add_column :post_images, :width, :integer
    add_column :post_images, :height, :integer
  end

  def self.down
    add_column :post_images, :width
    add_column :post_images, :height
  end
end
