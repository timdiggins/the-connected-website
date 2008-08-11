class Post < ActiveRecord::Base
  
  validates_presence_of :title, :detail
  belongs_to :user
  alias_attribute :to_s, :title
  
  named_scope :sorted_by_created, lambda { { :order => "updated_at DESC" }}
  
  
end
