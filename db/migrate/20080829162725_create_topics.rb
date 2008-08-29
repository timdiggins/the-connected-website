class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
    
    create_table :categorizations do |t|
      t.belongs_to :topic
      t.belongs_to :post
      t.timestamps
    end
  end

  def self.down
    drop_table :categorizations
    drop_table :topics
  end
end
