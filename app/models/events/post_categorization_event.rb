class PostCategorizationEvent < ActiveRecord::Base
  
  self.abstract_class = true  
  
  belongs_to :tag
  belongs_to :post
  belongs_to :user

end