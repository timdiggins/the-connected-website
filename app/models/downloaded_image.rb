
class DownloadedImage < ActiveRecord::Base
  has_one :post_image
  has_attachment(:content_type => :image, 
                 :storage => ATTACHMENT_FU_STORAGE, 
                 :thumbnails => { :crop64 => [64,64], :crop128 => [128,128], :crop256 => [256,256], :width640 => '640x', :height320=> 'x320' }, 
  :max_size => 10.megabytes, :processor => 'ImageScience'
  )
  
  validates_as_attachment
  
  def attachment_attributes_valid?
    errors.add_to_base("Uploaded file is too large (10MB max).") if attachment_options[:size] && !attachment_options[:size].include?(send(:size))
    errors.add_to_base("Uploaded file has invalid content.") if attachment_options[:content_type] && !attachment_options[:content_type].include?(send(:content_type))
  end
  
end
