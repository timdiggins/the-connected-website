class ChangeGroupsProfileTextToBeLonger < ActiveRecord::Migration
  def self.up
    change_column :groups, :profile_text, :text
  end

  def self.down
    change_column :groups, :profile_text, :string
    end
end
