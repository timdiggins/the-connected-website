
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

      post = Post.new(:title => title, :detail => simple_format(content), :user => user)
      puts post.inspect
      post.save!

      i += 1
    end
end


if __FILE__ == $0
  go
end