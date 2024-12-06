class ApplicationNotifier < Noticed::Event
  deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"
  #
  #
  # notification_methods do
  #   def data
  #     {
  #       title: title,
  #       body: body,
  #       url: url,
  #       record_id: record.id,
  #       record_type: record.class.name
  #     }
  #   end

  #   def title
  #     params[:title]
  #   rescue
  #     "title missing"
  #   end

  #   def body
  #     params[:message]
  #   rescue
  #     "message missing"
  #   end

  #   def url
  #     "/"
  #   end
  # end
end
