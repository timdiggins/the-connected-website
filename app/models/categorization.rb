class Categorization < ActiveRecord::Base
  
  belongs_to :topic
  belongs_to :post
  
end
