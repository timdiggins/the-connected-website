APP_DOMAIN = Rails.env == 'production' ? "theconnectedrepublic.org/" : "republic.dev"
APP_PORT = Rails.env == 'production' ? "" : ":3000"
APP_HOST = APP_DOMAIN + APP_PORT

APP_NAME = "The Connected Republic"
