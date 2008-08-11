class Avatar < ActiveRecord::Base
  belongs_to      :user
  has_attachment  :content_type => :image, :storage => :file_system, :thumbnails => { :tiny => '32x32>', :small => '48x48>', :medium => '64x64>', :large => '128x128>' }, :max_size => 60.kilobytes, :processor => 'ImageScience'
  validates_as_attachment

  def attachment_attributes_valid?
    errors.add_to_base("Uploaded file is too large (5MB max).") if attachment_options[:size] && !attachment_options[:size].include?(send(:size))
    errors.add_to_base("Uploaded file has invalid content.") if attachment_options[:content_type] && !attachment_options[:content_type].include?(send(:content_type))
  end

end


