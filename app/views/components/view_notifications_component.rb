# frozen_string_literal: true

class ViewNotificationsComponent < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag

  def view_template
    return unless Current.user
    div do
      button(
        type: "button",
        data: {
          navigation_target: "viewNotificationsButton",
          action: "touchstart->navigation#tapNotificationDrop click->navigation#tapNotificationDrop click@window->navigation#hideNotificationDrop"
        },
        class:
          "relative rounded-full bg-transparent p-1 text-blue-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800",
        id: "user-notifications-button",
        aria_expanded: "false",
        aria_haspopup: "true"
      ) do
        span(class: "absolute -inset-1.5")
        span(class: "sr-only") { "View notifications" }
        render NotificationBell.new(recipient: Current.user)
      end
      div(
        class:
          "hidden absolute right-8 z-10 mt-2 w-96 text-sm px-2 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        role: "menu",
        data: { navigation_target: "viewNotifications" },
        aria_orientation: "vertical",
        aria_labelledby: "user-notifications-button",
        tabindex: "-1"
      ) do
        nots = Current.user.notifications.unread
        h1(class: "text-xl mb-4") { helpers.t("notifications", name: Current.user.name, count: nots.count) }
        div(class: "h-1/2 max-h-64 overflow-y-auto overflow-x-hidden", data: { turbo_prefetch: "false" }) do
          turbo_frame_tag("notifications") do
            ul(role: "notification_list", class: "divide-y divide-gray-100") do
              nots.newest_first.each do |notification|
                # render partial: "notifications/notification", locals: { notification: notification }
                render NotificationItem.new(notification: notification)
              end
            end
          end
        end
      end
    end
  end
end
