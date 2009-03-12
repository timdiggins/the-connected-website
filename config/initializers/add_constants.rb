APP_DOMAIN = Rails.env == 'production' ? "portfolios.red56.co.uk" : "portfolios.dev"
APP_PORT = Rails.env == 'production' ? "" : ":3000"
APP_HOST = APP_DOMAIN + APP_PORT

APP_NAME = "Portfolios - Architecture - Open Studio"
