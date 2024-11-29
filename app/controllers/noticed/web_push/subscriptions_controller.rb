# frozen_string_literal: true

class Noticed::WebPush::SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    params.permit![:unsubscribe] ?
      unsubscribe :
      subscribe

    head :ok
  end

  def subscribe
    Noticed::WebPush::Subscription.find_or_create_by!(user: current_user, endpoint: params[:endpoint], auth_key: params[:keys][:auth], p256dh_key: params[:keys][:p256dh])
  end

  def unsubscribe
    sub = Noticed::WebPush::Subscription.find_by(user: current_user, endpoint: params[:endpoint], auth_key: params[:keys][:auth], p256dh_key: params[:keys][:p256dh])
    sub.destroy if sub
  end
end

# TODO
# - replace AppController
# - replace current_user
