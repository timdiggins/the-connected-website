class Post < ActiveRecord::Base
  
  validates_presence_of :title, :detail
  belongs_to :user
  alias_attribute :to_s, :title
  
end
