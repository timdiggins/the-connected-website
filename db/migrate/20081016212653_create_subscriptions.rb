class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :post
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
