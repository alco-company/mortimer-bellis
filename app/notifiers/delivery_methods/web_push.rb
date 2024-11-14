class DeliveryMethods::WebPush < ApplicationDeliveryMethod
  def deliver
    return unless recipient.is_a?(User)

    recipient.web_push_subscriptions.each do |subscription|
      subscription.publish(notification.data)
    end
  end
end
