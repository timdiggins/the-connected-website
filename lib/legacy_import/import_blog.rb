require "rubygems"
require 'hpricot'

xml = %{
<status>
  <id>1</id>
  <created_at>a date</created_at>
  <text>some text</text>
</status> 
}

doc = open("blog.xml") { |f| Hpricot.XML(f) }
(doc/:item).each do |item|
  
  puts '-------------------------------'
  
  title = item.at(:title).inner_html
  pub_date = item.at(:pubDate).inner_html
  creator = item.at("dc:creator").inner_html
  content = item.at("content:encoded").inner_html.sub(/^\<\!\[CDATA\[/, '').sub(/\]\]>$/, '')
  
  puts title
  puts pub_date
  puts creator
  puts content
    # puts "#{item.innerHTML}" 
end