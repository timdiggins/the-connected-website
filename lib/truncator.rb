module Truncator
  
  def truncate_html_text(html_text, length = 500)
    truncate_string = "..."
    sanitized = HTML::FullSanitizer.new.sanitize(html_text)
    
    l = length - truncate_string.mb_chars.length
    (sanitized.mb_chars.length > length ? sanitized.mb_chars[0...l] + truncate_string : sanitized).to_s
  end
  
  
end