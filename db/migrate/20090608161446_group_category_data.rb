class GroupCategoryData < ActiveRecord::Migration
  def self.up
    GroupCategory.destroy_all
    GroupCategory.new(:name=>'Degree').save!() 
    GroupCategory.new(:name=>'Diploma').save!() 
    GroupCategory.new(:name=>'MA').save!() 
    GroupCategory.new(:name=>'Research').save!() 
    other = GroupCategory.new(:name=>'Other')
    other.save!()
    
    Group.all.each do |group|
      other.groups << group   
    end
  end
  
  def self.down
    GroupCategory.destroy_all
    Group.all.each do |group|
      group.category = nil
      group.save!
    end
  end
end
