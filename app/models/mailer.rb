class Mailer < ActionMailer::Base
  
  def forgot_password(user, url)
    @from = "#{APP_NAME} Passwords <do-not-reply@#{APP_DOMAIN}>"
    @subject = "Your password"
    @sent_on     = Time.now
    @body[:user] = user
    @recipients  = "#{user} <#{user.email}>"
    @body[:url]  = url
  end

end
