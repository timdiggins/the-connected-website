class GroupCategory < ActiveRecord::Base
  has_many :groups, :order=>'groups.name ASC'
  
  alias_attribute :to_s, :name
end
