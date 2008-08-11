class Post < ActiveRecord::Base
  
  validates_presence_of :title, :detail
  belongs_to :user
  alias_attribute :to_s, :title
  
  named_scope :sorted_by_created, lambda { { :order => "updated_at DESC" }}
  
  def brief
    truncate(detail, 200)
  end

  private
    def truncate(text, length)
      truncate_string = "..."
      l = length - truncate_string.chars.length
      (text.chars.length > length ? text.chars[0...l] + truncate_string : text).to_s
    end
  
  
end
