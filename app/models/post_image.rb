class PostImage < ActiveRecord::Base
  belongs_to :post
  
  named_scope :latest3, :limit=>3, :order => "updated_at DESC"
  named_scope :featured, lambda { | limit | { :conditions => [ "post_images.featured_at IS NOT NULL" ], :order => "post_images.featured_at DESC" }} 
  named_scope :limit_to, lambda { | limit | { :limit => limit } }
  
  def width_for_height(h)
    return nil if self.width.nil? || self.height.nil? 
    h*self.width/self.height
  end
  def height_for_width(w)
    return nil if self.width.nil? || self.height.nil?
    w*self.height/self.width
  end
  
  def featured?
    !featured_at.nil?
  end
end
