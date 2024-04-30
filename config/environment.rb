# Load the Rails application.
require_relative "application"

ActionMailer::Base.smtp_settings = {
  :user_name => ENV['SMTP_USER_NAME'],
  :password => ENV['SMTP_PASSWORD'],
  :domain => ENV['SMTP_DOMAIN'],
  :address => ENV['SMTP_HOST'],
  :port => ENV['SMTP_PORT'],
  :authentication => ENV['SMTP_AUTHENTICATION'],
  :enable_starttls_auto => false
}

# Initialize the Rails application.
Rails.application.initialize!
