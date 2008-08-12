class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events, :force => true do |t|
      t.belongs_to :user
      t.belongs_to :detail, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
