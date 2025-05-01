
# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::Request

  attr_accessor :items

  def initialize(items: [], root: nil, locale: nil, time_zone: nil, menu: nil)
    @items = items
    @root = root
    @locale = locale
    @time_zone = time_zone
    @menu = menu || default_menu
  end

  def view_template
    nav(class: "flex flex-1 flex-col scrollbar-hide overflow-y-auto") do
      ul(role: "list", class: "flex flex-1 flex-col gap-y-7 px-2") do
        li(class: "") do
          ul(role: "list", class: "-mx-2 space-y-1") do
            @menu.each do |key, item|
              item[:submenu] ? sub_menu(key, item) : menu_item(item: item, icon: item[:icon])
            end
            li(class: "h-22") { unsafe_raw "&nbsp;" }
            li(class: "h-22") { unsafe_raw "&nbsp;" }
            li(class: "h-22") { unsafe_raw "&nbsp;" }
            li(class: "h-22") { unsafe_raw "&nbsp;" }
          end
        end
        if Current.get_user.tasks.uncompleted.any?
          li(data: { menu_target: "progress" }, class: "fixed bottom-13 w-[240px] bg-slate-50") do
            render Account::Progress.new
          end
        end
        help_and_shortcuts
      end
    end
  end

  # def mobile_menu_button
  #   comment { "Mobile menu button" }
  #   button(
  #     type: "button",
  #     data: { action: "click->navigation#toggleMenu" },
  #     class:
  #       "relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-sky-700 hover:text-white focus:outline-hidden focus:ring-1 focus:ring-inset focus:ring-cyan-300",
  #     aria_controls: "mobile-menu",
  #     aria_expanded: "false"
  #   ) do
  #     span(class: "absolute -inset-0.5")
  #     span(class: "sr-only") { "Open main menu" }
  #     comment do
  #       %(Icon when menu is closed. Menu open: "hidden", Menu closed: "block")
  #     end
  #     svg(
  #       class: "block h-6 w-6",
  #       data: { navigation_target: "menuClose" },
  #       fill: "none",
  #       viewbox: "0 0 24 24",
  #       stroke_width: "1.5",
  #       stroke: "currentColor",
  #       aria_hidden: "true"
  #     ) do |s|
  #       s.path(
  #         stroke_linecap: "round",
  #         stroke_linejoin: "round",
  #         d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
  #       )
  #     end
  #     comment do
  #       %(Icon when menu is open. Menu open: "block", Menu closed: "hidden")
  #     end
  #     svg(
  #       class: "hidden h-6 w-6",
  #       data: { navigation_target: "menuOpen" },
  #       fill: "none",
  #       viewbox: "0 0 24 24",
  #       stroke_width: "1.5",
  #       stroke: "currentColor",
  #       aria_hidden: "true"
  #     ) do |s|
  #       s.path(
  #         stroke_linecap: "round",
  #         stroke_linejoin: "round",
  #         d: "M6 18L18 6M6 6l12 12"
  #       )
  #     end
  #   end
  # end

  # def desktop_menu
  #   div(class: "flex space-x-4 py-4") do
  #     comment do
  #       %(Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white")
  #     end
  #     # a(
  #     #   href: helpers.root_path,
  #     #   class:
  #     #     "mort-nav-link",    # bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium
  #     #   aria_current: "page"
  #     # ) { I18n.t "menu.home" }
  #     items.each do |item|
  #       a(
  #         href: item[:url],
  #         class:
  #           "mort-nav-link", # bg-gray-900 text-white block rounded-md px-3 py-2 text-sm font-medium
  #         aria_current: "page"
  #       ) { item[:title] }
  #     end
  #   end
  # end

  # def mobile_menu
  #   comment { "Mobile menu, show/hide based on menu state." }
  #   div(data: { navigation_target: "mobileMenu" }, class: "hidden lg:hidden", id: "mobile-menu") do
  #     div(class: "space-y-1 px-2 pb-3 pt-2") do
  #       a(
  #         href: @root || helpers.root_path,
  #         class:
  #           "mort-nav-link",
  #         aria_current: "page"
  #       ) { "Hjem" }
  #       items.each do |item|
  #         a(
  #           href: item[:url],
  #           class:
  #             "mort-nav-link",
  #           aria_current: "page"
  #         ) { item[:title] }
  #       end
  #     end
  #   end
  # end

  # def view_notifications
  #   return unless Current.user
  #   render Notifications::NotificationBell.new recipient: Current.user

  #   # div do
  #   #   button(
  #   #     type: "button",
  #   #     data: {
  #   #       navigation_target: "viewNotificationsButton",
  #   #       action: "touchstart->navigation#tapNotificationDrop click->navigation#tapNotificationDrop click@window->navigation#hideNotificationDrop"
  #   #     },
  #   #     class:
  #   #       "relative rounded-full bg-transparent p-1 text-blue-300 hover:text-white focus:outline-hidden focus:ring-1 focus:ring-white focus:ring-offset-1 focus:ring-offset-gray-800",
  #   #     id: "user-notifications-button",
  #   #     aria_expanded: "false",
  #   #     aria_haspopup: "true"
  #   #   ) do
  #   #     span(class: "absolute -inset-1.5")
  #   #     span(class: "sr-only") { "View notifications" }
  #   #     render NotificationBell.new(recipient: Current.user)
  #   #   end
  #   #   div(
  #   #     class:
  #   #       "hidden absolute right-8 z-10 mt-2 w-96 text-sm px-2 origin-top-right rounded-md  py-1 shadow-lg ring-1 ring-slate-100 focus:outline-hidden",
  #   #     role: "menu",
  #   #     data: { navigation_target: "viewNotifications" },
  #   #     aria_orientation: "vertical",
  #   #     aria_labelledby: "user-notifications-button",
  #   #     tabindex: "-1"
  #   #   ) do
  #   #     nots = Current.user.notifications.unread
  #   #     h1(class: "text-xl mb-4") { helpers.t("notifications", name: Current.user.name, count: nots.count) }
  #   #     div(class: "h-1/2 max-h-64 overflow-y-auto overflow-x-hidden", data: { turbo_prefetch: "false" }) do
  #   #       turbo_frame_tag("notifications") do
  #   #         ul(role: "notification_list", class: "divide-y divide-gray-100") do
  #   #           nots.newest_first.each do |notification|
  #   #             # render partial: "notifications/notification", locals: { notification: notification }
  #   #             render NotificationItem.new(notification: notification)
  #   #           end
  #   #         end
  #   #       end
  #   #     end
  #   #   end
  #   # end
  # end

  # def profile_dropdown
  #   render ProfileDropmenuComponent.new
  # end


  private

    def default_menu
      # return {
      #   dashboard: { title: "dashboard", url: "/dashboards/show_dashboard", icon: "home" },
      #   time_material: { title: "time_material", url: "/time_materials", icon: "time_material" },
      #   # calendar: { title: "calendar", url: "/calendars", icon: "calendar" },
      #   # reports: { title: "Reports", url: "/pages", icon: "home" },
      #   manage: { title: "manage",
      #     submenu: {
      #       # background_jobs: { title: "background_jobs", url: "/background_jobs", icon: "background_job" },
      #       customers: { title: "customers", url: "/customers", icon: "customer" },
      #       # dashboards: { title: "dashboards", url: "/dashboards", icon: "home" },
      #       # invoices: { title: "invoices", url: "/invoices", icon: "invoice" },
      #       # invoice_items: { title: "invoice_items", url: "/invoice_items", icon: "invoice_item" },
      #       # kiosks: { title: "kiosks", url: "/punch_clocks", icon: "punch_clock" },
      #       # locations: { title: "locations", url: "/locations", icon: "location" },
      #       products: { title: "products", url: "/products", icon: "product" },
      #       projects: { title: "projects", url: "/projects", icon: "project" },
      #       # punches: { title: "punches", url: "/punches", icon: "punch" },
      #       # reports: { title: "Reports", url: "/reports", icon: "home" },
      #       # teams: { title: "teams", url: "/teams", icon: "team" },
      #       # tenants: { title: "tenants", url: "/tenants", icon: "tenant" },
      #       provided_services: { title: "integrations", url: "/provided_services", icon: "extension" },
      #       settings: { title: "settings", url: "/settings", icon: "setting" },
      #       # oauths: { title: "oauth_applications", url: "/oauth/applications", icon: "oauth" },
      #       users: { title: "users", url: "/users", icon: "user" }
      #     }
      #   }
      # } unless Current.user.superadmin?
      {
        dashboard: { title: "dashboard", url: "/dashboards/show_dashboard", icon: "home" },
        time_material: { title: "time_material", url: "/time_materials", icon: "time_material" },
        # calendar: { title: "calendar", url: "/calendars", icon: "calendar" },
        # reports: { title: "Reports", url: "/pages", icon: "home" },
        manage: { title: "manage",
          submenu: {
            background_jobs: { title: "background_jobs", url: "/background_jobs", icon: "background_job", license: "ambassador pro" },
            customers: { title: "customers", url: "/customers", icon: "customer" },
            dashboards: { title: "dashboards", url: "/dashboards", icon: "home", license: "ambassador pro" },
            filters: { title: "filters", url: "/filters", icon: "filter", license: "ambassador pro" },
            invoices: { title: "invoices", url: "/invoices", icon: "invoice", license: "ambassador pro" },
            invoice_items: { title: "invoice_items", url: "/invoice_items", icon: "invoice_item", license: "ambassador pro" },
            kiosks: { title: "kiosks", url: "/punch_clocks", icon: "punch_clock", license: "ambassador pro" },
            locations: { title: "locations", url: "/locations", icon: "location", license: "ambassador pro" },
            products: { title: "products", url: "/products", icon: "product" },
            projects: { title: "projects", url: "/projects", icon: "project", license: "ambassador pro" },
            punches: { title: "punches", url: "/punches", icon: "punch", license: "ambassador pro" },
            # reports: { title: "Reports", url: "/reports", icon: "home" },
            tasks: { title: "tasks", url: "/tasks", icon: "task", license: "ambassador pro" },
            teams: { title: "teams", url: "/teams", icon: "team", license: "ambassador pro" },
            tenants: { title: "tenants", url: "/tenants", icon: "tenant" },
            provided_services: { title: "integrations", url: "/provided_services", icon: "extension", license: "ambassador pro" },
            settings: { title: "settings", url: "/settings", icon: "setting" },
            # oauths: { title: "oauth_applications", url: "/oauth/applications", icon: "oauth" },
            users: { title: "users", url: "/users", icon: "user", license: "essential ambassador pro" }
          }
        }
      }
    end

    def current_item?(url)
      return request.path.split("?")[0] == "/" ? "bg-gray-50" : "" if url == "/"
      request.path.split("?")[0].include?(url) ? "bg-sky-100" : ""
    end

    def menu_item(item:, icon: nil)
      # %(Current: "bg-gray-50", Default: "hover:bg-gray-50")
      item[:license] ||= "free ambassador essential pro"
      url = item[:url]
      css = "group flex gap-x-3 rounded-md  p-2 text-sm font-semibold leading-6 text-sky-400 hover:text-sky-800 hover:bg-gray-50"
      css = "#{css} #{current_item?(url)}"
      title = item[:title]
      li do
        a(href: url, class: css, data: { action: "click->mobilesidebar#hide" }) do
          render_icon(icon) if icon
          span(class: "", data: { menu_target: "menuitem" }) { I18n.t("menu.#{title}") }
        end
      end if item[:license].include?(Current.tenant.license) || item[:license].blank? || Current.user.superadmin?
    end

    def expanded_sub?(item)
      item[:submenu].each do |key, i|
        return "rotate-90 text-gray-500" if request.path.split("?")[0].include?(i[:url])
      end
      "text-gray-400"
    end

    def hidden_sub?(item)
      item[:submenu].each do |key, i|
        return "block" if request.path.split("?")[0].include?(i[:url])
      end
      "hidden"
    end

    def sub_menu(text, item)
      return if Current.user.user?
      li do
        div do
          button(
            type: "button",
            data: { action: "click->menu#toggleSubmenu" },
            class:
              "flex w-full items-center gap-x-3 rounded-md p-2 text-left text-sm font-semibold leading-6 text-sky-400 hover:text-sky-800 hover:bg-gray-50",
            aria_controls: "sub-menu-1",
            aria_expanded: "false"
          ) do
            # comment do
            #   %(Expanded: "rotate-90 text-gray-500", Collapsed: "text-gray-400")
            # end
            svg(
              class: "pointer-events-none h-5 w-5 shrink-0 #{expanded_sub?(item)}",
              viewbox: "0 0 20 20",
              fill: "currentColor",
              aria_hidden: "true"
            ) do |s|
              s.path(
                fill_rule: "evenodd",
                d:
                  "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z",
                clip_rule: "evenodd"
              )
            end
            span(class: "", data: { menu_target: "menuitem" }) { I18n.t("menu.#{text}") }
          end
          # comment do
          #   "Expandable link section, show/hide based on state."
          # end
          ul(class: "submenu #{hidden_sub?(item)} mt-1 px-0", id: "sub-menu-1") do
            item[:submenu].each do |key, i|
              next if key == :tenants && !Current.user.superadmin?
              menu_item(item: i, icon: i[:icon])
            end
          end
        end
      end
    rescue
    end

    def help_and_shortcuts
      li(class: "fixed bottom-0") do
        comment { "w-24 max-w-24 w-64" }
        ul(role: "list", class: "-mx-2 space-y-1") do
          div(data: { menu_target: "setting" }, class: " flex flex-row mt-auto  w-64  ") do
            # a(
            #   href: settings_url,
            #   class:
            #     "py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50"
            # ) do
            #   render_icon("setting")
            # end
            # a(
            #   href: provided_services_url,
            #   class:
            #     " py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50"
            # ) do
            #   render_icon("extension")
            # end
            a(
              data: { turbo_stream: "true" },
              role: "menuitem",
              tabindex: "-1",
              href: new_modal_url(resource_class: "page", modal_form: "keyboard"),
              class:
                "hidden px-2 py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50 md:block"
            ) do
              render_icon("keyboard")
            end
            a(
              href: "https://mortimer.pro/help",
              target: "_blank",
              class:
                " px-2 py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50"
            ) do
              render_icon("help", "h-6 text-red-500")
            end
            a(
              href: "https://mortimer.pro/contact",
              target: "_blank",
              class:
                " px-2 py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50"
            ) do
              render_icon("support_agent", "h-6 text-sky-500")
            end
          end
        end
      end
    end

    def render_icon(icon, cls = nil)
      cls ||= "h-6 text-sky-300 group-hover:text-sky-600"
      render "Icons::#{icon.camelcase}".constantize.new cls: cls
    end
end
