class AddExtraSizingToPostImages < ActiveRecord::Migration
  def self.up
    add_column :post_images, :width640_height, :integer
    add_column :post_images, :height320_width, :integer
  end

  def self.down
    remove_column :post_images, :height320_width
    remove_column :post_images, :width640_height
  end
end
