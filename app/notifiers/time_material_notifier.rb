# To deliver this notification:
#
# TimeMaterialNotifier.with(record: @post, message: "New post").deliver(User.all)

class TimeMaterialNotifier < ApplicationNotifier
  # Add your delivery methods
  # - other than ApplicationNotifier ones
  notification_methods do
    def data
      {
        title: title,
        body: body,
        url: url,
        record_id: record.id,
        record_type: record.class.name
      }
    end

    def title
      params[:title]
    rescue
      "title missing"
    end

    def body
      params[:message]
    rescue
      "message missing"
    end

    def url
      params[:url] || time_materials_path(record)
    rescue
      "/"
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
