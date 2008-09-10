class Post < ActiveRecord::Base
  
  validates_presence_of :title, :detail
  
  belongs_to :user
  has_many :comments, :order => 'created_at DESC', :dependent => :destroy
  has_many :categorizations
  has_many :topics, :through => :categorizations, :uniq => true
  
  named_scope :sorted_by_created_at, lambda { { :order => "created_at DESC" }}
  named_scope :sorted_by_updated_at, lambda { { :order => "updated_at DESC" }}
  named_scope :featured, lambda { { :conditions => [ "featured_at IS NOT NULL" ], :order => "featured_at DESC", :limit => 5 }} 
  
  alias_attribute :to_s, :title
  
  def brief
    truncate(detail, 500)
  end
  
  def featured?
    !featured_at.nil?
  end

  private
    def truncate(text, length)
      truncate_string = "..."
      l = length - truncate_string.chars.length
      (text.chars.length > length ? text.chars[0...l] + truncate_string : text).to_s
    end
  
  
end
