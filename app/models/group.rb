class Group < ActiveRecord::Base
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
