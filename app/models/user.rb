require 'digest/sha1'

class User < ActiveRecord::Base
  attr_accessor :password, :uploaded_avatar_data
  attr_writer :password_required
  
  attr_protected            :admin
  validates_presence_of     :login, :email 
  validates_presence_of     :password, :if => :password_required?
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  before_save :encrypt_password
  before_destroy :has_no_creations!
  has_one :avatar, :dependent => :destroy
  has_many :comments
  has_many :events, :order => 'created_at DESC'
  has_many :group_permissions, :include => :group, :uniq => true, :dependent=>:destroy
  
  alias_attribute :to_s, :login
  
  named_scope :recently_contributed, lambda { | limit | { :limit => limit, :order => "contributed_at DESC" } }
  named_scope :recently_signed_up, :limit => 10, :order => "created_at DESC" 
  named_scope :order_by_created_at, :order => "created_at DESC" 
  named_scope :created_since, lambda { | the_date | { :conditions => [ "created_at > ?", the_date ] } }
  named_scope :has_bio_and_avatar, :include => :avatar, :conditions => [ "profile_text <> ? AND avatars.filename <> ?", '', '']
  
  def self.authenticate(login, password)
    u = find_by_login(login) 
    if u && u.authenticated?(password)
      u.track_login
      u
    else
      nil
    end
  end
  
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def encrypt(password)
    self.class.encrypt(password, salt)
  end
  
  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  def remember_me
    self.remember_token_expires_at = Time.mktime(2035)
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def make_reset_password_token
    self.update_attribute(:reset_password_token, Digest::SHA1.hexdigest(Time.now.to_s.split(//).concat(login.split(//)).sort_by { rand }.join))
  end 
  
  def to_param
    login
  end
  
  def user_avatar=(it)  
    the_avatar = self.avatar || Avatar.new
    the_avatar.uploaded_data = it
    self.avatar = the_avatar unless it.to_s.blank?  
  end
  
  def possessive_to_s
    result = "#{self}'"
    result += "s" unless to_s.ends_with?('s')
    result
  end
  
  def track_login
    self.update_attribute(:last_login_at, Time.now)
    self.increment!(:login_count)
  end
  
  def self.find_by_login!(login)
    user = self.find(:first, :conditions => { :login => login })
    raise ActiveRecord::RecordNotFound, "Couldn't find User with login '#{login}'" unless user
    user
  end
  
  
  def has_creations
    comments.count > 0 || events.count > 0
  end
  
  def has_no_creations!
    raise "Has creations (dependencies)" if has_creations
  end
  
  def destroy_creations
    comments.destroy_all
    events.destroy_all
  end
  
  def can_edit? group_or_post_or_user
    if group_or_post_or_user.class == Post
      post = group_or_post_or_user
      return self.can_edit?(post.author)
    end
    if group_or_post_or_user.class==User
      user = group_or_post_or_user
      return user.id == self.id
    end
    group = group_or_post_or_user
    return false unless group.class == Group
    group_permissions.each do |gp|
      return true if group.id == gp.group_id
    end
    false
  end
  
  private
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    @password_required || crypted_password.blank? || !@password.blank?
  end
  
end
