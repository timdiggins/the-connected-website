class Group < ActiveRecord::Base
  validates_uniqueness_of   :name, :case_sensitive => false
  has_many :group_permissions, :include => :user, :uniq => true, :dependent=>:destroy
  has_many :rss_feeds, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :post_images, :through => :posts, :order => "post_images.updated_at DESC"
  
  belongs_to :group_category
  
  alias_attribute :to_s, :name
  alias_attribute :category, :group_category
  alias_attribute :images, :post_images
  
  named_scope :order_by_contributed_at, lambda {  { :conditions=>"contributed_at is not NULL", :order => "contributed_at DESC" } }
  
  def to_param
    name
  end
  
  def self.find_by_name!(name)
    group = self.find(:first, :conditions => { :name => name })
    raise ActiveRecord::RecordNotFound, "Couldn't find Group with name '#{name}'" unless group
    group
  end
  
  def avatar
    nil
  end
  
  def latest_image
    post_images.featured.first
  end
  def latest3_images
    post_images.featured.limit_to(3)
  end
  
  def has_feed_problem?
    rss_feeds.each do |feed|
      return true if feed.has_problem?
    end
    false
  end
end
