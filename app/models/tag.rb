class Tag < ActiveRecord::Base
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  has_many :categorizations, :dependent => :destroy
  has_many :posts, :through => :categorizations, :uniq => true
  alias_attribute :to_s, :name
  
  def to_param
    name
  end
  
  def self.find_by_name!(name)
    tag = self.find(:first, :conditions => { :name => name })
    raise ActiveRecord::RecordNotFound, "Couldn't find Tag named '#{name}'" unless tag
    tag
  end
  
end
