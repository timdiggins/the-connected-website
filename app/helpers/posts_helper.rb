module PostsHelper
  
  def detail_format(detail)
    stripped = h(detail)
    linked = auto_link(stripped) { | each | each[/\.(jpg|gif|png)$/] ? %Q{<img src="#{each}" width="160px" class="embeddedImage" />} : each }
    simple_format(linked)
  end
  
  def when_changed(post) 
    prefix = (post.created_at == post.updated_at) ? "created" : "last updated"
    "#{prefix} #{time_ago_in_words(post.updated_at)} ago"
  end
end
