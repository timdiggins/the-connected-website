module PostsHelper
  
  def when_changed(post) 
    prefix = (post.created_at == post.updated_at) ? "created" : "last updated"
    "#{prefix} #{time_ago_in_words(post.updated_at)} ago"
  end
  
  def render_posts(xml, posts)
    for post in posts
      xml.item do
        xml.title post.title
        xml.description post.detail
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post_url(post)
        xml.author(post.user)               
        xml.guid(post_url(post))
      end
    end
  end
end
