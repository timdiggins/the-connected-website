class FeaturedWhen < ActiveRecord::Migration
  def self.up
    remove_column :posts, :featured
    add_column :posts, :featured_at, :datetime
  end

  def self.down
    remove_column :posts, :featured_at
    add_column :posts, :featured, :boolean,   :default => false
  end
end
