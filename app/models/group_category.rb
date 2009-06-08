class GroupCategory < ActiveRecord::Base
  has_many :groups
  
  alias_attribute :to_s, :name
end
