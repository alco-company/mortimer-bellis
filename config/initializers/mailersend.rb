require "action_mailer/delivery_methods/mailersend"

ActionMailer::Base.add_delivery_method :mailersend,
  ActionMailer::DeliveryMethods::Mailersend,
  api_key: ENV["MAILERSEND_API_TOKEN"]
