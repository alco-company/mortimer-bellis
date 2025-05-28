# frozen_string_literal: true

class Noticed::WebPush::SubscriptionsController < BaseController
  def create
    require_authentication
    params.permit![:unsubscribe] ?
      unsubscribe :
      subscribe
  end

  def subscribe
    sub = Noticed::WebPush::Subscription.find_or_create_by!(user: Current.user, endpoint: params[:endpoint], auth_key: params[:keys][:auth], p256dh_key: params[:keys][:p256dh])
    enable = sub ? "hidden" : ""
    disabled = enable.blank? ? "hidden" : ""
    render turbo_stream: [
      # turbo_stream.replace("csrf_token", partial: "application/csrf_token"),
      turbo_stream.replace("notifications_outlet", partial: "users/registrations/notifications_outlet", locals: { enable: enable, disabled: disabled })
    ]
  end

  def unsubscribe
    sub = Noticed::WebPush::Subscription.find_by(user: Current.user, endpoint: params[:endpoint], auth_key: params[:keys][:auth], p256dh_key: params[:keys][:p256dh])
    sub.destroy if sub
    render turbo_stream: [
      turbo_stream.replace("notifications_outlet", partial: "users/registrations/notifications_outlet", locals: { enable: "", disabled: "hidden" })
    ]
  end
end
