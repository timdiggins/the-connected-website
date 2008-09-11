
def go
    require File.expand_path(File.dirname(__FILE__) + "/../../config/environment") 
    require "rubygems"
    require 'hpricot'

    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper


    doc = open("blog.xml") { |f| Hpricot.XML(f) }
    i = 1
    (doc/:item).each do |item|
      puts i
      puts '-------------------------------'
  
      title = item.at(:title).inner_html
      pub_date = item.at(:pubDate).inner_html
      creator = item.at("dc:creator").inner_html
      content = item.at("content:encoded").inner_html.sub(/^\<\!\[CDATA\[/, '').sub(/\]\]>$/, '')
  
      next if title.blank?
      next if content.blank?
      next if creator == 'admin'
  
      puts title.inspect
      puts pub_date
      puts creator
      user = User.find_by_login(creator) || User.find_by_name(creator)
      raise "Oops! No user!" unless user

      post = Post.new(:title => title, :detail => simple_format(content), :user => user, :created_at => pub_date)

      post.class.record_timestamps = false
      puts post.inspect
      event = Event.create_for(post)
      
      event.class.record_timestamps = false
      event.update_attribute(:created_at, post.created_at)
      event.update_attribute(:updated_at, post.created_at)
      post.update_attribute(:updated_at, post.created_at)
      puts post.inspect
      puts post.created_at.inspect

      (item/"wp:comment").each do | comment |
        author = comment.at("wp:comment_author").inner_html.sub(/^\<\!\[CDATA\[/, '').sub(/\]\]>$/, '')
        author_url = comment.at("wp:comment_author_url").inner_html.strip
        comment_date = comment.at("wp:comment_date_gmt").inner_html.strip
        content = comment.at("wp:comment_content").inner_html.strip
        
        # puts author
        # puts author_url
        # puts comment_date
        if author_url.blank?
          new_content = "#{author} said: #{content}"
        else
          new_content = %Q{<a href="#{author_url}">#{author}</a> said: #{content}}
        end
        
        
        
        comment = Comment.new(:body => simple_format(new_content), :created_at => comment_date)
        comment.post = post
        comment.user = User.find_by_login("Unknown User")

        
        event = Event.create_for(comment)
        event.class.record_timestamps = false
        comment.class.record_timestamps = false

        comment.update_attribute(:created_at, comment_date)
        comment.update_attribute(:updated_at, comment_date)
        puts "Added comment #{comment.inspect}"
        post.update_attribute(:updated_at, comment_date)
        event.update_attribute(:created_at, comment_date)
        event.update_attribute(:updated_at, comment_date)
        
        
      end


      i += 1
    end
end


if __FILE__ == $0
  go
end