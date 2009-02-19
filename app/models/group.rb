class Group < ActiveRecord::Base
  validates_uniqueness_of   :name, :case_sensitive => false
  has_many :group_permissions, :include => :user, :uniq => true, :dependent=>:destroy

  alias_attribute :to_s, :name

  def to_param
    name
  end

  def self.find_by_name!(name)
    group = self.find(:first, :conditions => { :name => name })
    raise ActiveRecord::RecordNotFound, "Couldn't find Group with name '#{name}'" unless group
    group
  end
  
end
