# To deliver this notification:
#
# TimeMaterialNotifier.with(record: @post, message: "New post").deliver(User.all)

class TimeMaterialNotifier < ApplicationNotifier
  # Add your delivery methods
  #
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"

  notification_methods do
    def data
      {
        title: I18n.t("time_material.new_assigned_task_title"),
        body: params[:message],
        record_id: record.id,
        record_type: record.class.name
      }
    end
  end
  # deliver_by :action_cable do |config|
  #   config.channel = "NotificationsChannel" # "Noticed::NotificationsChannel"
  #   config.stream = Current.notification_stream
  #   config.message = -> { params.merge(user_id: recipient.id) }
  # end

  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  #   config.wait = 15.minutes
  #   config.unless = -> { read? }
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
