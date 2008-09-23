class Comment < ActiveRecord::Base
  
  validates_tiny_mce_presence_of :body
  
  belongs_to :user
  belongs_to :post
    
end
