class Post < ActiveRecord::Base
  
  include Truncator
  
  attr_accessor :specifying_video, :specifying_upload
  validates_presence_of :title
  validates_presence_of :video, :if => :specifying_video
  validate :must_have_attachment
  validates_tiny_mce_presence_of :detail, :unless => :specifying_video
  
  belongs_to :user
  has_many :comments, :order => 'created_at', :dependent => :destroy
  
  has_one  :attachment, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :subscribers, :through => :subscriptions, :source => :user, :uniq => true
  
  has_many :categorizations, :dependent => :destroy
  has_many :tags, :through => :categorizations, :uniq => true
  
  named_scope :sorted_by_created_at, lambda { { :order => "created_at DESC" }}
  named_scope :sorted_by_updated_at, lambda { { :order => "updated_at DESC" }}
  named_scope :sorted_by_commented_at, lambda { { :order => "commented_at DESC" }}
  named_scope :featured, lambda { { :conditions => [ "featured_at IS NOT NULL" ], :order => "featured_at DESC", :limit => 6 }} 
  named_scope :limit_to, lambda { | limit | { :limit => limit } }
  
  alias_attribute :to_s, :title

  before_create do |post|
    post.commented_at = post.created_at
  end
  
  def brief
    truncate_html_text(detail)
  end
  
  def featured?
    !featured_at.nil?
  end
  
  def post_attachment=(it)  
    @in_upload_mode = true
    the_attachment = self.attachment || Attachment.new
    the_attachment.uploaded_data = it
    self.attachment = the_attachment unless it.to_s.blank?  
  end
  
  def video_embed_tags
    return nil if video.blank?
    object_tag = video.strip[/^<object.*<\/object>$/]
    return object_tag if object_tag
    
    uri = URI.parse(video.strip)   
    return nil unless uri.query
    
    host_parts = uri.host.split('.')
    domain = host_parts[-2]
    return nil unless domain == "youtube"
    
    query_parts = uri.query.split('&')
    v_param = query_parts.select { | each | each.starts_with?("v=") }.first
    return nil unless v_param
    v_value = v_param[/v=(.*)/, 1]
    
    %Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/#{v_value}&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/#{v_value}&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
    
  rescue URI::InvalidURIError    
  end
  
  def has_attachment?
    !attachment.nil?
  end
  
  def has_video?
    !video.blank?
  end
  
  private
  def must_have_attachment
    errors.add_to_base("Must select a file to upload") if @in_upload_mode && (!attachment || attachment.filename.blank?)
  end
   
end
