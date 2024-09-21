# frozen_string_literal: true

class MenuComponent < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo

  def initialize **attribs, &block
    @user = attribs[:user]
    @menu = {
      workzone: {
        url: "#",
        desc: "Get a better understanding where your traffic is coming from",
        sub_menu: {
          dashboard: {
            url: "/",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          time: {
            url: "/punches",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          Calendar: {
            url: "/calendars",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          reports: {
            url: "#",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          }
        },
        sub_menu_footer: [ {
          text: "Watch the demo",
          url: "#",
          icon: "
            svg(
              class: 'h-5 w-5 flex-none text-gray-400',
              viewbox: '0 0 20 20',
              fill: 'currentColor',
              aria_hidden: 'true'
            ) do |s|
              s.path(
                fill_rule: 'evenodd',
                d:
                  'M2 10a8 8 0 1116 0 8 8 0 01-16 0zm6.39-2.908a.75.75 0 01.766.027l3.5 2.25a.75.75 0 010 1.262l-3.5 2.25A.75.75 0 018 12.25v-4.5a.75.75 0 01.39-.658z',
                clip_rule: 'evenodd'
              )
            end
          "
          }, {
          text: "Watch the demo",
          url: "#",
          icon: "
            svg(
              class: 'h-5 w-5 flex-none text-gray-400',
              viewbox: '0 0 20 20',
              fill: 'currentColor',
              aria_hidden: 'true'
            ) do |s|
              s.path(
                fill_rule: 'evenodd',
                d:
                  'M2 10a8 8 0 1116 0 8 8 0 01-16 0zm6.39-2.908a.75.75 0 01.766.027l3.5 2.25a.75.75 0 010 1.262l-3.5 2.25A.75.75 0 018 12.25v-4.5a.75.75 0 01.39-.658z',
                clip_rule: 'evenodd'
              )
            end
          "
          }
        ]
      },
      manage: {
        url: "#",
        desc: "Get a better understanding where your traffic is coming from",
        sub_menu: {
          kiosks: {
            url: "/punch_clocks",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          teams: {
            url: "/teams",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          users: {
            url: "/users",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          punches: {
            url: "/punches",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          locations: {
            url: "/locations",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          }
        },
        sub_menu_footer: [ {
          text: "Kiosks",
          url: "/punch_clocks",
          icon: "
            svg(
              class: 'h-5 w-5 flex-none text-gray-400',
              viewbox: '0 0 20 20',
              fill: 'currentColor',
              aria_hidden: 'true'
            ) do |s|
              s.path(
                fill_rule: 'evenodd',
                d:
                  'M2 10a8 8 0 1116 0 8 8 0 01-16 0zm6.39-2.908a.75.75 0 01.766.027l3.5 2.25a.75.75 0 010 1.262l-3.5 2.25A.75.75 0 018 12.25v-4.5a.75.75 0 01.39-.658z',
                clip_rule: 'evenodd'
              )
            end
          "
          }, {
          text: "Calendars",
          url: "/calendars",
          icon: "
            svg(
              class: 'h-5 w-5 flex-none text-gray-400',
              viewbox: '0 0 20 20',
              fill: 'currentColor',
              aria_hidden: 'true'
            ) do |s|
              s.path(
                fill_rule: 'evenodd',
                d:
                  'M2 10a8 8 0 1116 0 8 8 0 01-16 0zm6.39-2.908a.75.75 0 01.766.027l3.5 2.25a.75.75 0 010 1.262l-3.5 2.25A.75.75 0 018 12.25v-4.5a.75.75 0 01.39-.658z',
                clip_rule: 'evenodd'
              )
            end
          "
          }, {
          text: "Reports",
          url: "/pages",
          icon: "
            svg(
              class: 'h-5 w-5 flex-none text-gray-400',
              viewbox: '0 0 20 20',
              fill: 'currentColor',
              aria_hidden: 'true'
            ) do |s|
              s.path(
                fill_rule: 'evenodd',
                d:
                  'M2 10a8 8 0 1116 0 8 8 0 01-16 0zm6.39-2.908a.75.75 0 01.766.027l3.5 2.25a.75.75 0 010 1.262l-3.5 2.25A.75.75 0 018 12.25v-4.5a.75.75 0 01.39-.658z',
                clip_rule: 'evenodd'
              )
            end
          "
          }
        ]
      },
      extensions: {
        url: "#",
        desc: "Get a better understanding where your traffic is coming from",
        sub_menu: {
          projects: {
            url: "#",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          tags: {
            url: "#",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          },
          planning: {
            url: "#",
            desc: "Get a better understanding where your traffic is coming from",
            icon: "
              svg(
                class:
                  'h-6 w-6 text-gray-600 group-hover:text-indigo-600',
                fill: 'none',
                viewbox: '0 0 24 24',
                stroke_width: '1.5',
                stroke: 'currentColor',
                aria_hidden: 'true'
              ) do |s|
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z')
                s.path(stroke_linecap: 'round', stroke_linejoin: 'round', d: 'M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z')
              end
            "
          }
        },
        sub_menu_footer: []
      },
      settings: { url: "#", desc: "Speak directly to your customers with our engagement tool" },
      help: { url: "#", desc: "Speak directly to your customers with our engagement tool" }
    }
  end

  def view_template
    cs = @user.nil? ? "hidden" : ""
    header(class: "#{cs} relative isolate z-10 bg-white", data: { controller: "menu navigation" }) do
      desktop_menu()
      mobile_menu()
    end
  end

  #
  # Desktop menu, show/hide based on menu open state.
  #
  def desktop_menu
    nav(class: "mx-auto flex max-w-7xl items-center justify-between lg:px-8", aria_label: "Global") do
      logo()
      hamburger()
      main_menu()
      div(class: "hidden lg:flex lg:flex-1 lg:justify-end") do
        view_notifications
        profile_dropdown
      end
    end
  end

  #
  # "Mobile menu, show/hide based on menu open state.
  #
  def mobile_menu
    div(class: "lg:hidden", role: "dialog", aria_modal: "true") do
      whitespace
      comment { "Background backdrop, show/hide based on slide-over state." }
      div(class: "fixed inset-0 z-10")
      div(class: "fixed inset-y-0 right-0 z-10 w-full overflow-y-auto bg-white px-6 py-6 sm:max-w-sm sm:ring-1 sm:ring-gray-900/10") do
        div(class: "flex items-center justify-between") do
          whitespace
          a(href: "#", class: "-m-1.5 p-1.5") do
            whitespace
            span(class: "sr-only") { "Your Company" }
            whitespace
            img(
              class: "h-8 w-auto",
              src:
                "https://tailwindui.com/img/logos/mark.svg?color=indigo&shade=600",
              alt: ""
            )
            whitespace
          end
          whitespace
          button(
            type: "button",
            class: "-m-2.5 rounded-md p-2.5 text-gray-700"
          ) do
            whitespace
            span(class: "sr-only") { "Close menu" }
            whitespace
            svg(
              class: "h-6 w-6",
              fill: "none",
              viewbox: "0 0 24 24",
              stroke_width: "1.5",
              stroke: "currentColor",
              aria_hidden: "true"
            ) do |s|
              s.path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                d: "M6 18L18 6M6 6l12 12"
              )
            end
            whitespace
          end
        end
        div(class: "mt-6 flow-root") do
          div(class: "-my-6 divide-y divide-gray-500/10") do
            div(class: "space-y-2 py-6") do
              div(class: "-mx-3") do
                whitespace
                button(
                  type: "button",
                  class:
                    "flex w-full items-center justify-between rounded-lg py-2 pl-3 pr-3.5 text-base font-semibold leading-7 text-gray-900 hover:bg-gray-50",
                  aria_controls: "disclosure-1",
                  aria_expanded: "false"
                ) do
                  plain " Product "
                  comment do
                    %(Expand/collapse icon, toggle classes based on menu open state. Open: "rotate-180", Closed: "")
                  end
                  whitespace
                  svg(
                    class: "h-5 w-5 flex-none",
                    viewbox: "0 0 20 20",
                    fill: "currentColor",
                    aria_hidden: "true"
                  ) do |s|
                    s.path(
                      fill_rule: "evenodd",
                      d:
                        "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z",
                      clip_rule: "evenodd"
                    )
                  end
                  whitespace
                end
                whitespace
                comment do
                  "'Product' sub-menu, show/hide based on menu state."
                end
                div(class: "mt-2 space-y-2", id: "disclosure-1") do
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "Analytics" }
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "Engagement" }
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "Security" }
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "Integrations" }
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "Watch demo" }
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "Contact sales" }
                  whitespace
                  a(
                    href: "#",
                    class:
                      "block rounded-lg py-2 pl-6 pr-3 text-sm font-semibold leading-7 text-gray-900 hover:bg-gray-50"
                  ) { "View all products" }
                end
              end
              whitespace
              a(
                href: "#",
                class:
                  "-mx-3 block rounded-lg px-3 py-2 text-base font-semibold leading-7 text-gray-900 hover:bg-gray-50"
              ) { "Features" }
              whitespace
              a(
                href: "#",
                class:
                  "-mx-3 block rounded-lg px-3 py-2 text-base font-semibold leading-7 text-gray-900 hover:bg-gray-50"
              ) { "Marketplace" }
              whitespace
              a(
                href: "#",
                class:
                  "-mx-3 block rounded-lg px-3 py-2 text-base font-semibold leading-7 text-gray-900 hover:bg-gray-50"
              ) { "Company" }
            end
            div(class: "py-6") do
              whitespace
              a(
                href: "#",
                class:
                  "-mx-3 block rounded-lg px-3 py-2.5 text-base font-semibold leading-7 text-gray-900 hover:bg-gray-50"
              ) { "Log in" }
            end
          end
        end
      end
    end
  end

  #
  # logo
  #
  def logo
    div(class: "flex lg:flex-1") do
      a(href: "#", class: "-m-1.5 p-1.5") do
        span(class: "sr-only") { "Your Company" }
        render LogoComponent.new div_css: "relative left-0 flex-shrink-0 pb-5 lg:static"
      end
    end
  end

  def hamburger
    div(class: "flex lg:hidden") do
      button(
        type: "button",
        class:
          "-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
      ) do
        span(class: "sr-only") { "Open main menu" }
        svg(
          class: "h-6 w-6",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          aria_hidden: "true"
        ) do |s|
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
          )
        end
      end
    end
  end

  def view_notifications
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

  def profile_dropdown
    return unless Current.user
    div(class: " relative ml-3") do
      div do
        button(
          type: "button",
          data: {
            navigation_target: "profileMenuButton",
            action: "touchstart->navigation#tapDrop click->navigation#tapDrop click@window->navigation#hideDrop"
          },
          class:
            "relative flex rounded-full bg-sky-200 text-sm focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800",
          id: "user-menu-button",
          aria_expanded: "false",
          aria_haspopup: "true"
        ) do
          span(class: "absolute -inset-1.5")
          span(class: "sr-only") { "Open user menu" }
          if Current.user
            if Current.user.mugshot.attached?
              image_tag(Current.user.mugshot, class: "h-8 w-8 rounded-full")
            else
              image_tag("icons8-customer-64.png", class: "h-8 w-8 rounded-full")
            end
          end
          # helpers.user_mugshot(Current.user.mugshot, css: "h-8 w-8 rounded-full")
          # img(
          #   class: "h-8 w-8 rounded-full",
          #   src:
          #     "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
          #   alt: ""
          # )
        end
      end
      #
      # Dropdown menu, show/hide based on menu state.
      # Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100"
      # Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      #
      div(
        class:
          "hidden absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        role: "menu",
        data: { navigation_target: "profileMenu" },
        aria_orientation: "vertical",
        aria_labelledby: "user-menu-button",
        tabindex: "-1"
      ) do
        comment { %(Active: "bg-gray-100", Not Active: "") }
        p(class: "text-sm font-medium px-4 py-2") { Current.user.name }
        hr
        link_to("Your Profile", edit_user_registration_path, class: "block px-4 py-2 text-sm text-gray-700", role: "menuitem", tabindex: "-1", id: "user-menu-item-0")
        # link_to( "Settings", "#", class: "block px-4 py-2 text-sm text-gray-700", role: "menuitem", tabindex: "-1", id: "user-menu-item-1")
        link_to("Sign out", destroy_user_session_path(), class: "block px-4 py-2 text-sm text-gray-700", method: :delete, data: { turbo_method: :delete }, role: "menuitem", tabindex: "-1", id: "user-menu-item-2")
      end
    end
  end

  def main_menu
    div(class: "hidden lg:flex lg:gap-x-12") do
      @menu.each do |key, item|
        if item[:sub_menu]
          main_menu_with_sub(key.to_s.titleize) do
            svg(
              class: "h-5 w-5 flex-none text-gray-400",
              viewbox: "0 0 20 20",
              fill: "currentColor",
              aria_hidden: "true"
            ) do |s|
              s.path(
                fill_rule: "evenodd",
                d:
                  "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z",
                clip_rule: "evenodd"
              )
            end
            flyout_menu(item)
          end
        else
          main_menu_item(key.to_s.titleize, item[:url])
        end
      end
    end
  end
  #
  # main menu with sub
  #
  def main_menu_with_sub(text, &block)
    div do
      sub_menu_button(text, &block)
    end
  end
  #
  # flyout_menu
  #
  def flyout_menu(items)
    #
    #
    # 'Product' flyout menu, show/hide based on flyout menu state.
    # Entering: "transition ease-out duration-200"
    # From: "opacity-0 -translate-y-1"
    # To: "opacity-100 translate-y-0"
    # Leaving: "transition ease-in duration-150"
    # From: "opacity-100 translate-y-0"
    # To: "opacity-0 -translate-y-1")
    #
    #
    div(class: "hidden flyout absolute inset-x-0 top-0 -z-10 bg-white pt-14 shadow-lg ring-1 ring-gray-900/5") do
      div(class: "mx-auto grid max-w-7xl grid-cols-4 gap-x-4 px-6 py-10 lg:px-8 xl:gap-x-8") do
        items[:sub_menu].each do |key, item|
          second_level_menu_item(key.to_s.titleize, item) do
            eval(item[:icon])
            # svg(
            #   class:
            #     "h-6 w-6 text-gray-600 group-hover:text-indigo-600",
            #   fill: "none",
            #   viewbox: "0 0 24 24",
            #   stroke_width: "1.5",
            #   stroke: "currentColor",
            #   aria_hidden: "true"
            # ) do |s|
            #   s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z")
            #   s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z")
            # end
          end
        end
        # second_level_menu_item("Engagement", "#", "Speak directly to your customers with our engagement tool") do
        #   svg(
        #     class:
        #       "h-6 w-6 text-gray-600 group-hover:text-indigo-600",
        #     fill: "none",
        #     viewbox: "0 0 24 24",
        #     stroke_width: "1.5",
        #     stroke: "currentColor",
        #     aria_hidden: "true"
        #   ) do |s|
        #     s.path(
        #       stroke_linecap: "round",
        #       stroke_linejoin: "round",
        #       d:
        #         "M15.042 21.672L13.684 16.6m0 0l-2.51 2.225.569-9.47 5.227 7.917-3.286-.672zM12 2.25V4.5m5.834.166l-1.591 1.591M20.25 10.5H18M7.757 14.743l-1.59 1.59M6 10.5H3.75m4.007-4.243l-1.59-1.59"
        #     )
        #   end
        # end
        # second_level_menu_item("Security", "#", "Your customers' data will be safe and secure") do
        #   svg(
        #     class:
        #       "h-6 w-6 text-gray-600 group-hover:text-indigo-600",
        #     fill: "none",
        #     viewbox: "0 0 24 24",
        #     stroke_width: "1.5",
        #     stroke: "currentColor",
        #     aria_hidden: "true"
        #   ) do |s|
        #     s.path(
        #       stroke_linecap: "round",
        #       stroke_linejoin: "round",
        #       d:
        #         "M7.864 4.243A7.5 7.5 0 0119.5 10.5c0 2.92-.556 5.709-1.568 8.268M5.742 6.364A7.465 7.465 0 004.5 10.5a7.464 7.464 0 01-1.15 3.993m1.989 3.559A11.209 11.209 0 008.25 10.5a3.75 3.75 0 117.5 0c0 .527-.021 1.049-.064 1.565M12 10.5a14.94 14.94 0 01-3.6 9.75m6.633-4.596a18.666 18.666 0 01-2.485 5.33"
        #     )
        #   end
        # end
        # second_level_menu_item("Integration", "#", "Your customers' data can be integrated all over the place") do
        #   svg(
        #     class:
        #       "h-6 w-6 text-gray-600 group-hover:text-indigo-600",
        #     fill: "none",
        #     viewbox: "0 0 24 24",
        #     stroke_width: "1.5",
        #     stroke: "currentColor",
        #     aria_hidden: "true"
        #   ) do |s|
        #     s.path(
        #       stroke_linecap: "round",
        #       stroke_linejoin: "round",
        #       d:
        #         "M13.5 16.875h3.375m0 0h3.375m-3.375 0V13.5m0 3.375v3.375M6 10.5h2.25a2.25 2.25 0 002.25-2.25V6a2.25 2.25 0 00-2.25-2.25H6A2.25 2.25 0 003.75 6v2.25A2.25 2.25 0 006 10.5zm0 9.75h2.25A2.25 2.25 0 0010.5 18v-2.25a2.25 2.25 0 00-2.25-2.25H6a2.25 2.25 0 00-2.25 2.25V18A2.25 2.25 0 006 20.25zm9.75-9.75H18a2.25 2.25 0 002.25-2.25V6A2.25 2.25 0 0018 3.75h-2.25A2.25 2.25 0 0013.5 6v2.25a2.25 2.25 0 002.25 2.25z"
        #     )
        #   end
        # end
      end
      second_level_menu_footer(items[:sub_menu_footer])
    end
  end
  #
  # main menu item
  #
  def main_menu_item(text, url)
    a(href: url, class: "text-sm font-semibold leading-6 text-gray-900", data: { turbo_frame: "_top" }) { text }
  end
  #
  # sub menu button
  #
  def sub_menu_button(text, &block)
    button(
      type: "button",
      data: { menu_target: "flyout", action: "click->menu#toggleFlyout" },
      class: "flex items-center gap-x-1 text-sm font-semibold leading-6 text-gray-900",
      aria_expanded: "false"
    ) do
      plain text
      yield
    end
  end

  #
  # second level menu item
  #
  def second_level_menu_item(text, item, &block)
    div(class: "group relative rounded-lg p-6 text-sm leading-6 hover:bg-gray-50") do
      div(class: "flex h-11 w-11 items-center justify-center rounded-lg bg-gray-50 group-hover:bg-white") do
        yield
      end
      a(href: item[:url], class: "mt-6 block font-semibold text-gray-900", data: { turbo_frame: "_top" }) do
        plain text
        span(class: "absolute inset-0")
      end
      p(class: "mt-1 text-gray-600") do
        plain item[:desc]
      end
    end
  end

  #
  # second_level_menu_footer
  #
  def second_level_menu_footer(items)
    div(class: "bg-gray-50") do
      div(class: "mx-auto max-w-7xl px-6 lg:px-8") do
        div(class: "grid grid-cols-3 divide-x divide-gray-900/5 border-x border-gray-900/5") do
          items.each do |item|
            second_level_menu_footer_item(item[:text], item[:url]) do
              eval(item[:icon])
              # svg(
              #   class: "h-5 w-5 flex-none text-gray-400",
              #   viewbox: "0 0 20 20",
              #   fill: "currentColor",
              #   aria_hidden: "true"
              # ) do |s|
              #   s.path(
              #     fill_rule: "evenodd",
              #     d:
              #       "M2 10a8 8 0 1116 0 8 8 0 01-16 0zm6.39-2.908a.75.75 0 01.766.027l3.5 2.25a.75.75 0 010 1.262l-3.5 2.25A.75.75 0 018 12.25v-4.5a.75.75 0 01.39-.658z",
              #     clip_rule: "evenodd"
              #   )
              # end
            end
          end
          # second_level_menu_footer_item("Contact sales", "#") do
          #   svg(
          #     class: "h-5 w-5 flex-none text-gray-400",
          #     viewbox: "0 0 20 20",
          #     fill: "currentColor",
          #     aria_hidden: "true"
          #   ) do |s|
          #     s.path(
          #       fill_rule: "evenodd",
          #       d:
          #         "M2 3.5A1.5 1.5 0 013.5 2h1.148a1.5 1.5 0 011.465 1.175l.716 3.223a1.5 1.5 0 01-1.052 1.767l-.933.267c-.41.117-.643.555-.48.95a11.542 11.542 0 006.254 6.254c.395.163.833-.07.95-.48l.267-.933a1.5 1.5 0 011.767-1.052l3.223.716A1.5 1.5 0 0118 15.352V16.5a1.5 1.5 0 01-1.5 1.5H15c-1.149 0-2.263-.15-3.326-.43A13.022 13.022 0 012.43 8.326 13.019 13.019 0 012 5V3.5z",
          #       clip_rule: "evenodd"
          #     )
          #   end
          # end
          # second_level_menu_footer_item("View all products", "#") do
          #   svg(
          #     class: "h-5 w-5 flex-none text-gray-400",
          #     viewbox: "0 0 20 20",
          #     fill: "currentColor",
          #     aria_hidden: "true"
          #   ) do |s|
          #     s.path(
          #       fill_rule: "evenodd",
          #       d:
          #         "M2.5 3A1.5 1.5 0 001 4.5v4A1.5 1.5 0 002.5 10h6A1.5 1.5 0 0010 8.5v-4A1.5 1.5 0 008.5 3h-6zm11 2A1.5 1.5 0 0012 6.5v7a1.5 1.5 0 001.5 1.5h4a1.5 1.5 0 001.5-1.5v-7A1.5 1.5 0 0017.5 5h-4zm-10 7A1.5 1.5 0 002 13.5v2A1.5 1.5 0 003.5 17h6a1.5 1.5 0 001.5-1.5v-2A1.5 1.5 0 009.5 12h-6z",
          #       clip_rule: "evenodd"
          #     )
          #   end
          # end
        end
      end
    end
  end

  #
  # second level menu footer item
  #
  def second_level_menu_footer_item(text, url, &block)
    a(href: url, data: { turbo_frame: "_top" }, class: "flex items-center justify-center gap-x-2.5 p-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-100") do
      yield
      plain text
    end
  end
end
