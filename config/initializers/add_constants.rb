APP_DOMAIN = Rails.env == 'production' ? "wminarch.red56.co.uk" : "wminarch.dev"
APP_PORT = Rails.env == 'production' ? "" : ":3000"
APP_HOST = APP_DOMAIN + APP_PORT

APP_NAME = "University of Westminster - Architecture - Open Studio"
