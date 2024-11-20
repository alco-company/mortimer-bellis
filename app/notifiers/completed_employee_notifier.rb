# To deliver this notification:
#
# CompletedUserNotifier.with(record: @post, message: "New post").deliver(User.all)

class CompletedEmployeeNotifier < ApplicationNotifier
  # Add your delivery methods
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"
  # deliver_by :action_cable do |config|
  #   config.channel = "Noticed::NotificationsChannel"
  #   config.stream = -> { recipient }
  #   config.message = -> { params.merge(user_id: recipient.id) }
  # end
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  #   config.params = ->(recipient) { { user: recipient } }
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message
end
