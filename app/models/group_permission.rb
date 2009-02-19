class GroupPermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  
  def self.find_by_group_and_user(options)
    group = options[:group]
    user = options[:user]
    gp = self.find(:first, :conditions=>{:group_id=>group.id, :user_id=>user.id})
    raise ActiveRecord::RecordNotFound, "can't find GroupPermission with group_id=#{group} user_id=#{user}" if gp.nil?
    gp 
  end
end
