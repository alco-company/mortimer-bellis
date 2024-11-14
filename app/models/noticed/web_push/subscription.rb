module Noticed::WebPush
  class Subscription < ActiveRecord::Base
    self.table_name= "noticed_web_push_subs"
    belongs_to :user, polymorphic: true
    encrypts :endpoint, deterministic: true
    encrypts :auth_key, deterministic: true
    encrypts :p256dh_key, deterministic: true

    def publish(data)
      WebPush.payload_send(
        message: data.to_json,
        endpoint: endpoint,
        p256dh: p256dh_key,
        auth: auth_key,
        vapid: {
          private_key: Rails.application.credentials.dig(:web_push, :vapid_private_key),
          public_key: Rails.application.credentials.dig(:web_push, :vapid_public_key)
        }
      )
    end
  end
end
