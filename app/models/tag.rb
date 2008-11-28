class Tag < ActiveRecord::Base
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  has_many :categorizations, :dependent => :destroy
  has_many :posts, :through => :categorizations, :uniq => true
  alias_attribute :to_s, :name
  
  def to_param
    name
  end
  
  def self.find_by_name!(name)
    tag = self.find(:first, :conditions => { :name => name })
    raise ActiveRecord::RecordNotFound, "Couldn't find Tag named '#{name}'" unless tag
    tag
  end
  
  def self.all_with_count(options = {})
    query =  'SELECT tags.id, name, count(*) as count FROM categorizations, tags '
    query << ' WHERE tags.id = tag_id GROUP BY tag_id'
    query << " ORDER BY count DESC "
    query << " LIMIT #{options[:limit].to_i} " if options[:limit] != nil 
    self.find_by_sql(query).sort_by{|tag| tag.name.downcase}
  end
  
  def count
    count = read_attribute(:count)
    return nil if count == nil
    count.to_i
  end
end
