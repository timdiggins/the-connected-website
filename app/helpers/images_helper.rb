module ImagesHelper
  def image_tag_for(image, size)
    case size
      when :tiny_square then image_tag(image.src, :height=>32, :width=>32)
      when :small_square then image_tag(image.src, :height=>48, :width=>38)
      when :medium_square then image_tag(image.src, :height=>64, :width=>64)
      when :large_square then image_tag(image.src, :height=>128, :width=>128)
      #    => { :tiny => '32x32>', :small => '48x48>', :medium => '64x64>', :large => '128x128>' } 
      #-- a crop -- smaller size scale down to x and then crop and right or up and down to x
      when :strip then  image_tag(image.src, :height=>128, :width=>image.width_for_height(128))
      #- to fit 100 high - as wide as it needs.... 
      #store width
      
      when :contact then  image_tag(image.src, :height=>256, :width=>256)
      #  square 240 x 240 square - (with transparent padding) 
      #contact sheet
      
      when :medium then image_tag(image.src, :width=>500, :height=>image.height_for_width(128))
      #  500 wide 
      #store height (nil if original is smaller than 500 wide)
      
      when :large then image_tag(image.src,:width=>1000, :height=>image.height_for_width(1000))
      #  1024 wide (nil if original is smaller than 1024 wide) 
      #store height
      
      when :original then  image_tag(image.src) 
      #width and height
    else
      raise Exception, "wasn't expecting a size of #{size} for image"
    end
  end
end
