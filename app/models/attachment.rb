class Attachment < ActiveRecord::Base
  belongs_to      :post
  has_attachment  :content_type => [ 'application/pdf' ], :storage => :s3, :max_size => 10.megabytes
  validates_as_attachment

  def attachment_attributes_valid?
    errors.add_to_base("Uploaded file is too large (10MB max).") if attachment_options[:size] && !attachment_options[:size].include?(send(:size))
    errors.add_to_base("Uploaded file has invalid content.") if attachment_options[:content_type] && !attachment_options[:content_type].include?(send(:content_type))
  end

end

