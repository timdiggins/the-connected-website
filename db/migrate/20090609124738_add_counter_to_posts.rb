class AddCounterToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :post_images_count, :integer
    
    Post.reset_column_information
    Post.find(:all).each do |p|
      Post.update_counters p.id, :post_images_count => p.images.length
    end
  end
  
  def self.down
    remove_column :posts, :post_images_count
  end
end
