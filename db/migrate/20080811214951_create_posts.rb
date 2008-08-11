class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.belongs_to :user
      t.string :title
      t.text :detail
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
