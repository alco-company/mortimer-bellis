class Notifications::NotificationItem < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :notification

  def initialize(notification:, &block)
    @notification = notification
  end

  def view_template(&block)
    li(class: "", data_controller: "contextmenu") do
      div(class: "group relative flex items-center px-5 py-6") do
        a(href: "#", class: "-m-1 block flex-1 p-1") do
          div(
            class: "absolute inset-0 group-hover:bg-gray-50",
            aria_hidden: "true"
          )
          div(class: "relative flex min-w-0 flex-1 items-center") do
            span(class: "relative inline-block shrink-0") do
              img(
                class: "size-10 rounded-full",
                src:
                  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
                alt: ""
              )
              comment { %(Online: "bg-green-400", Offline: "bg-gray-300") }
              span(
                class:
                  "absolute right-0 top-0 block size-2.5 rounded-full bg-green-400 ring-2 ring-white",
                aria_hidden: "true"
              )
            end
            div(class: "ml-4 truncate") do
              p(class: "truncate text-sm font-medium text-gray-900") do
                "Leslie Alexander"
              end
              p(class: "truncate text-sm text-gray-500") { "@lesliealexander" }
            end
          end
        end
        div(class: "relative ml-2 inline-block shrink-0 text-left") do
          button(
            type: "button",
            data_contextmenu_target: "button",
            data_action:
              " touchstart->contextmenu#tap:passive click->contextmenu#tap click@window->contextmenu#hide",
            class:
              # "flex items-center p-1 text-gray-400 rounded-md hover:text-gray-900 border h-7 -mr-0.5 pl-3",
              "flex items-center rounded-md ring-1 ring-gray-100 bg-white px-2 py-1 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-500",
            id: "options-menu-0-button",
            aria_expanded: "false",
            aria_haspopup: "true"
          ) do
            span(class: "sr-only") { "Open list options" }
            # span(class: "text-2xs hidden sm:inline") { I18n.t("more") }
            render Icons::More.new
          end
          context_menu
        end
      end
    end
  end

  def context_menu
    comment do
      %(Dropdown panel, show/hide based on dropdown state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
    end
    div(
      data: {
        contextmenu_target: "popup",
        transition_enter: "transition ease-out duration-300",
        transition_enter_start: "transform opacity-0 scale-95",
        transition_enter_end: "transform opacity-100 scale-100",
        transition_leave: "transition ease-in duration-75",
        transition_leave_start: "transform opacity-100 scale-100",
        transition_leave_end: "transform opacity-0 scale-95"
      },
      class: "hidden absolute right-9 top-0 z-10 w-48 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-slate-100 focus:outline-hidden",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      div(class: "py-1", role: "none") do
        comment do
          %(Active: "bg-gray-100 text-gray-900 outline-hidden", Not Active: "text-gray-700")
        end
        a(
          href: "#",
          class: "block px-4 py-2 text-sm text-gray-200",
          role: "menuitem",
          tabindex: "-1",
          disabled: "disabled",
          id: "options-menu-0-item-0"
        ) { "View profile" }
        a(
          href: "#",
          class: "block px-4 py-2 text-sm text-gray-700",
          role: "menuitem",
          tabindex: "-1",
          id: "options-menu-0-item-1"
        ) { I18n.t("notification.read_message") }
      end
    end
  end

  def old_view_template(&block)
    div(class: "flex items-center justify-between gap-x-6 py-5 overflow-y-scroll") do
      div(class: "min-w-0") do
        div(class: "flex items-start gap-x-3") do
          p(class: "text-sm font-semibold leading-6 text-gray-900") do
            plain notification.event.params[:message]
          end
          # p(
          #   class:
          #     "mt-0.5 whitespace-nowrap rounded-md bg-green-50 px-1.5 py-0.5 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
          # ) { "Complete" }
        end
        div(
          class:
            "mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500"
        ) do
          p(class: "whitespace-nowrap") do
            plain I18n.t("notification_sent_at")
            time(datetime: I18n.l(notification.created_at, format: :short_iso)) { I18n.l(notification.created_at, format: :short) }
          end
          whitespace
          svg(viewbox: "0 0 2 2", class: "h-0.5 w-0.5 fill-current") do |s|
            s.circle(cx: "1", cy: "1", r: "1")
          end
          # p(class: "truncate") { "Created by Leslie Alexander" }
        end
      end
      div(class: "flex flex-none items-center gap-x-4") do
        whitespace
        a(
          href: helpers.notification_url(notification),
          data: { turbo_stream: true },
          class:
            "hidden rounded-md bg-white px-2.5 py-1.5 text-xs font-semibold text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:block"
        ) do
          plain I18n.t("mark_as_read")
          span(class: "sr-only") {  }
        end
        div(class: "relative flex-none") do
          whitespace
          button(
            type: "button",
            class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
            id: "options-menu-0-button",
            aria_expanded: "false",
            aria_haspopup: "true"
          ) do
            whitespace
            span(class: "sr-only") { "Open options" }
            whitespace
            svg(
              class: "h-5 w-5",
              viewbox: "0 0 20 20",
              fill: "currentColor",
              aria_hidden: "true"
            ) do |s|
              s.path(
                d:
                  "M10 3a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM10 8.5a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM11.5 15.5a1.5 1.5 0 10-3 0 1.5 1.5 0 003 0z"
              )
            end
            whitespace
          end
          whitespace
          comment do
            %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
          end
          div(
            class:
              "hidden absolute right-0 z-10 mt-2 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-hidden",
            role: "menu",
            aria_orientation: "vertical",
            aria_labelledby: "options-menu-0-button",
            tabindex: "-1"
          ) do
            whitespace
            comment { %(Active: "bg-gray-50", Not Active: "") }
            whitespace
            a(
              href: "#",
              class: "block px-3 py-1 text-sm leading-6 text-gray-900",
              role: "menuitem",
              tabindex: "-1",
              id: "options-menu-0-item-0"
            ) do
              plain "Edit"
              span(class: "sr-only") { ", GraphQL API" }
            end
            whitespace
            a(
              href: "#",
              class: "block px-3 py-1 text-sm leading-6 text-gray-900",
              role: "menuitem",
              tabindex: "-1",
              id: "options-menu-0-item-1"
            ) do
              plain "Move"
              span(class: "sr-only") { ", GraphQL API" }
            end
            whitespace
            a(
              href: "#",
              class: "block px-3 py-1 text-sm leading-6 text-gray-900",
              role: "menuitem",
              tabindex: "-1",
              id: "options-menu-0-item-2"
            ) do
              plain "Delete"
              span(class: "sr-only") { ", GraphQL API" }
            end
          end
        end
      end
    end
  end
end
