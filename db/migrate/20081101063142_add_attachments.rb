class AddAttachments < ActiveRecord::Migration
  def self.up
    create_table "attachments" do |t|
      t.belongs_to :post
      t.string   :content_type, :filename, :thumbnail
      t.integer  :size, :width, :height, :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table "attachments"
  end
end
