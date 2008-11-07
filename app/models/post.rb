class Post < ActiveRecord::Base

  include Truncator
  
  validates_presence_of :title
  validate :must_have_attachment
  validates_tiny_mce_presence_of :detail
  
  belongs_to :user
  has_many :comments, :order => 'created_at', :dependent => :destroy
  
  has_one  :attachment, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :subscribers, :through => :subscriptions, :source => :user, :uniq => true
  
  has_many :categorizations, :dependent => :destroy
  has_many :tags, :through => :categorizations, :uniq => true
  
  named_scope :sorted_by_created_at, lambda { { :order => "created_at DESC" }}
  named_scope :sorted_by_updated_at, lambda { { :order => "updated_at DESC" }}
  named_scope :featured, lambda { { :conditions => [ "featured_at IS NOT NULL" ], :order => "featured_at DESC", :limit => 6 }} 
  named_scope :limit_to, lambda { | limit | { :limit => limit } }
  
  alias_attribute :to_s, :title
  
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
    video
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
