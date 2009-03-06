class PostImage < ActiveRecord::Base
  belongs_to :post
  
  named_scope :latest3, :limit=>3, :order => "updated_at DESC"
  named_scope :featured
  
  def width_for_height(h)
    return nil if self.width.nil? || self.height.nil? 
    h*self.width/self.height
  end
  def height_for_width(w)
    return nil if self.width.nil? || self.height.nil?
    w*self.height/self.width
  end
end
