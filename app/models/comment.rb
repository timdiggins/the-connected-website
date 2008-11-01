class Comment < ActiveRecord::Base
  
  include Truncator
  validates_tiny_mce_presence_of :body
  
  belongs_to :user
  belongs_to :post
    

  def brief
    truncate_html_text(body)
  end
  
  def email_brief
    brief.gsub(/&nbsp;/, "\r\n")
  end
  
end
