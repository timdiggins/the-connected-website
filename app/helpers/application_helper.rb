module ApplicationHelper
  def clear_this
    %Q{<div class="clearThis"> </div>}
  end
  
  def tag_cloud(tags, classes)
    # based on http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
    max, min = 0, nil
    tags.each do |tag|
      max = tag.count if tag.count > max
      min = tag.count if min==nil || tag.count < min 
    end
    return if min.nil?
    divisor =  ((max-min) / classes.size) + 1
    tags.each do |tag|
      index = ((tag.count - min) / divisor).to_i
      yield tag, classes[index]
    end
  end
  
  def plain_text(string)
    h(strip_tags(string))
  end
end
