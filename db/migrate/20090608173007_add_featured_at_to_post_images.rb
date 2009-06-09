class AddFeaturedAtToPostImages < ActiveRecord::Migration
  def self.up
    add_column :post_images, :featured_at, :datetime
  end

  def self.down
    remove_column :post_images, :featured_at
  end
end
