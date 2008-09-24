xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{APP_NAME} (All Posts)"
    xml.description "#{APP_NAME} (All Posts)"
    xml.link posts_url

    render_posts(xml, @posts)
  end
end

