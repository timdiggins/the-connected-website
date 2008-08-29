require 'tlsmail'

smtp_password_path = File.join(CONFIG_PATH, 'smtp_password')

Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
God::Contacts::Email.server_settings = {
  :address => 'smtp.gmail.com',
  :tls => 'true',
  :port => 587,
  :authentication => :plain,
  :user_name => 'smtp@halethegeek.com',
  :password => File.read(smtp_password_path)
}