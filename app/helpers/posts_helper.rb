module PostsHelper
  
  def when_changed(post) 
    prefix = (post.created_at == post.updated_at) ? "created" : "last updated"
    "#{prefix} #{time_ago_in_words(post.updated_at)} ago"
  end
end
