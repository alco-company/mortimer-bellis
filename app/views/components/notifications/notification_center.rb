# frozen_string_literal: true

class Notifications::NotificationCenter < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag

  attr_accessor :recipient

  def initialize(recipient: nil)
    @recipient = recipient
  end

  def view_template
    return unless recipient
    div(
      data_notificationcenter_target: "notificationCenter",
      class: "hidden relative z-10",
      aria_labelledby: "slide-over-title",
      role: "dialog",
      aria_modal: "true"
    ) do
      div(
        aria_hidden: "true",
        data: {
          notificationcenter_target: "backdrop",
          transition_enter: "ease-in-out duration-500",
          transition_enter_start: "opacity-0",
          transition_enter_end: "opacity-100",
          transition_leave: "ease-in-out duration-500",
          transition_leave_start: "opacity-100",
          transition_leave_end: "opacity-0"
        },
        class: "fixed inset-0 bg-sky-300/20 ") { "" }
      div(class: "fixed inset-0 overflow-hidden") do
        div(class: "absolute inset-0 overflow-hidden") do
          div(class: "pointer-events-none fixed inset-y-0 top-16 right-0 flex max-w-full pl-10 sm:pl-16") do
            div(
              data: {
                notificationcenter_target: "slideoverpanel",
                transition_enter: "transform transition ease-in-out duration-500 sm:duration-1000",
                transition_enter_start: "translate-x-full",
                transition_enter_end: "translate-x-0",
                transition_leave: "transform transition ease-in-out duration-500 sm:duration-1000",
                transition_leave_start: "translate-x-0",
                transition_leave_end: "translate-x-full"
              },
              class: "pointer-events-auto w-screen max-w-md") do
              div(class: "flex h-full flex-col overflow-y-scroll bg-white shadow-xl") do
                div(class: "p-6") do
                  div(class: "flex items-start justify-between") do
                    div do
                      h2(class: "text-base font-semibold text-gray-900", id: "slide-over-title") { I18n.t("notifications_salutation", name: recipient.name) }
                      p { I18n.t("notifications", count: recipient.notifications.unread.count) }
                    end
                    div(class: "ml-3 flex h-7 items-center") do
                      button(
                        type: "button",
                        data_action: "notificationcenter#gong",
                        class:
                          "relative rounded-md bg-white text-gray-400 hover:text-gray-500 focus:ring-2 focus:ring-indigo-500"
                      ) do
                        span(class: "absolute -inset-2.5")
                        span(class: "sr-only") { "Close panel" }
                        render Icons::Cancel.new cls: "h-6 w-6 text-gray-400"
                      end
                    end
                  end
                end
                div(class: "border-b border-slate-100") do
                  div(class: "px-6") do
                    comment { "Tab component" }
                    nav(class: "-mb-px flex space-x-6") do
                      comment do
                        %(Current: "border-indigo-500 text-indigo-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
                      end
                      tab_link("All", "#",   "text-indigo-600 border-indigo-500")
                      tab_link("Chats", "#", "text-gray-500 border-transparent hover:border-gray-300 hover:text-gray-700")
                      tab_link("Other", "#", "text-gray-500 border-transparent hover:border-gray-300 hover:text-gray-700")
                    end
                  end
                end
                ul(role: "list", class: "flex-1 divide-y divide-gray-200 overflow-y-auto scrollbar-hide") do
                  # turbo_frame_tag "notifications_list" do
                  #   recipient.notifications.unread.each do |notification|
                  #     render Notifications::NotificationItem.new(notification: notification)
                  #   end
                  # end
                end
              end
            end
          end
        end
      end
    end
  end

  private
    def tab_link(text, href, css)
      a(
        href: href,
        class: "whitespace-nowrap border-b-2  border-slate-100 px-1 pb-4 text-sm font-medium #{css}"
      ) { text }
    end
end
