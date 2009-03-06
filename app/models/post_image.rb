class PostImage < ActiveRecord::Base
  belongs_to :post

  named_scope :latest3, :limit=>3, :order => "updated_at DESC"
  named_scope :featured
end
