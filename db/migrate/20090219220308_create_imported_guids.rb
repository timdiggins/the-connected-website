class CreateImportedGuids < ActiveRecord::Migration
  def self.up
    create_table :imported_guids do |t|
      t.string :guid
      t.belongs_to :rss_feed
      
      t.timestamps
    end
  end

  def self.down
    drop_table :imported_guids
  end
end
