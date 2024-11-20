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
# <!-- notifications bell -->
# <button type="button" class="relative rounded-full bg-white p-1 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:ring-offset-2">
#   <span class="absolute -inset-1.5"></span>
#   <span class="sr-only">View notifications</span>
#   <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true" data-slot="icon">
#     <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
#   </svg>
# </button>
