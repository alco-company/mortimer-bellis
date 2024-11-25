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
          subject: "mailto:monitor@mortimer.pro",
          private_key: ENV.fetch("VAPID_PRIVATE_KEY"),
          public_key: ENV.fetch("VAPID_PUBLIC_KEY")
        },
        ssl_timeout: 5,             # optional value for Net::HTTP#ssl_timeout=
        open_timeout: 5,            # optional value for Net::HTTP#open_timeout=
        read_timeout: 5             # optional value for Net::HTTP#read_timeout=
      )
    end
  end
end
