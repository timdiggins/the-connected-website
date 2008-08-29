class PostCategorizationEvent < ActiveRecord::Base
  
  self.abstract_class = true  
  
  belongs_to :topic
  belongs_to :post
  belongs_to :user

end