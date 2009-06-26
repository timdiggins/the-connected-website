module ImagesHelper
  def image_tag_for(image, size)
    if !image.downloaded?
      src = image.src  
    elsif size==:original
      src = image.downloaded.public_filename
    else
      src = image.downloaded.public_filename(size)
    end
    case size
      when :crop64 then image_tag(src, :height=>64, :width=>64)
      when :crop128 then image_tag(src, :height=>128, :width=>128)
      when :crop256 then  image_tag(src, :height=>256, :width=>256)
      when :width640 then image_tag(src,:width=>640, :height=>image.downloaded? ?  image.width640_height : image.height_for_width(640))
      when :height320 then  image_tag(src, :height=>320, :width=>image.downloaded? ? image.height320_width : image.width_for_height(320)) 
      when :original then  image_tag(src, :width=>image.width, :height=>image.height) 
    else
      raise Exception, "wasn't expecting a size of #{size} for image"
    end
  end
end
