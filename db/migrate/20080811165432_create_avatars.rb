class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars, :force => true do |t|
      t.belongs_to :user
      t.string :content_type, :filename, :thumbnail
      t.integer :size, :width, :height, :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table :avatars
  end
end
