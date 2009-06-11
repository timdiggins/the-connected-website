class CreateDownloadedImages < ActiveRecord::Migration
  def self.up
    create_table :downloaded_images do |t|
      t.belongs_to :post_image
      t.string :content_type, :filename, :thumbnail, :caption
      t.integer :size, :width, :height, :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :downloaded_images
  end
end
