APP_DOMAIN = Rails.env == 'production' ? "wminarch.org" : "website.dev"
APP_PORT = Rails.env == 'production' ? "" : ":3000"
APP_HOST = APP_DOMAIN + APP_PORT

APP_NAME = "University of Westminster - Architecture - Open Studios"
