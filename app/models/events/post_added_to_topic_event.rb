class PostAddedToTopicEvent < ActiveRecord::Base
  
  belongs_to :topic
  belongs_to :post
  belongs_to :user

end