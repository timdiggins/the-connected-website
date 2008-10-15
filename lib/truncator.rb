module Truncator
  
  def truncate_html_text(html_text, length = 500)
    truncate_string = "..."
    sanitized = HTML::FullSanitizer.new.sanitize(html_text)
    
    l = length - truncate_string.chars.length
    (sanitized.chars.length > length ? sanitized.chars[0...l] + truncate_string : sanitized).to_s
  end
  
  
end