# require 'spacesuit/recipes/backup'

set :deploy_to, "/var/www/apps/#{application}"
set :domain, "209.20.82.7"

set :user, 'republic'

role :web, domain
role :app, domain
role :db,  domain, :primary => true
