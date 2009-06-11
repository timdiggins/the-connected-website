class FixPostImageCounter < ActiveRecord::Migration
  def self.up
    change_column :posts, :post_images_count, :integer, :default=>0
    
    Post.reset_column_information
    Post.find(:all).each do |p|
      Post.update_counters p.id, :post_images_count => p.images.length
    end
  end

  def self.down
    change_column :posts, :post_images_count, :integer, :default=>nil
  end
end
