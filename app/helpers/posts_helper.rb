module PostsHelper
  
  def detail_format(detail)
    stripped = h(detail)
    linked = auto_link(stripped) { | each | each[/\.(jpg|gif|png)$/] ? %Q{<img src="#{each}" width="160px" class="embeddedImage" />} : each }
    simple_format(linked)
  end
  
end
