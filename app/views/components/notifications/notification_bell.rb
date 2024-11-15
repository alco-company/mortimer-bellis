class Notifications::NotificationBell < ApplicationComponent
  #
  def initialize(recipient: nil)
    @swing = recipient.notifications.unread.any? ? "animate-swing" : "" rescue ""
  end

  def view_template
    swing = Current.user.notifications.unread.any? ? "animate-swing" : "" rescue ""
    div(id: "notification_bell", data: { notificationcenter_target: "notificationBell" }) do
      button(
        id: "user-notifications-button",
        type: "button",
        data: {
          notificationcenter_target: "notificationBellButton",
          action: "touchstart->notificationcenter#gong click->notificationcenter#gong "
        },
        class: "-m-2.5 p-2.5 text-sky-200 hover:text-sky-600",
        aria_expanded: "false"
      ) do
        # span(class: "absolute -inset-1.5") - will bar the entire topbar :o
        span(class: "sr-only") { "View notifications" }
        div(id: "notification_bell") do
          render Icons::Bell.new cls: "h-6 text-sky-300 hover:text-sky-600 #{swing}"
        end
      end
    end
  end
end
