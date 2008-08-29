class Topic < ActiveRecord::Base
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  has_many :categorizations
  has_many :posts, :through => :categorizations, :uniq => true
  
end
