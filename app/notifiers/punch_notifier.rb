# To deliver this notification:
#
# PunchNotifier.with(record: @post, message: "New post").deliver(User.all)

class PunchNotifier < ApplicationNotifier
  # Add your delivery methods
  # - other than ApplicationNotifier ones

  notification_methods do
    def data
      title = params[:title] rescue "title missing"
      body = params[:message] rescue "message missing"
      url = params[:url] rescue "url missing"
      {
        title: title,
        body: body,
        url: url,
        record_id: record.id,
        record_type: record.class.name
      }
    end
  end
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
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
