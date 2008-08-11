class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login, :email, :remember_token, :crypted_password, :salt, :reset_password_token
      t.datetime :remember_token_expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
