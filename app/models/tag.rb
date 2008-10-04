class Tag < ActiveRecord::Base
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  has_many :categorizations, :dependent => :destroy
  has_many :posts, :through => :categorizations, :uniq => true
  alias_attribute :to_s, :name
  
end
