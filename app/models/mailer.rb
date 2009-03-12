class Mailer < ActionMailer::Base
  default_url_options[:host] = APP_HOST
  
  def forgot_password(user, url)
    @from = "#{APP_NAME} Passwords <do-not-reply@#{APP_DOMAIN}>"
    @subject = "Your password"
    @sent_on     = Time.now
    @body[:user] = user
    @recipients  = "#{user} <#{user.email}>"
    @body[:url]  = url
  end

  def comment_created(comment, recipient)
    @from = "#{APP_NAME} notifications <do-not-reply@#{APP_DOMAIN}>"
    @subject = "[portfolios] New comment on #{comment.post}"
    @sent_on = Time.now
    @recipients = [ recipient ]
    @body[:comment] = comment
    @body[:post_url] = post_url(comment.post)
    @headers["reply-to"] = "do_not_reply@#{APP_DOMAIN}"  
  end
  
end
