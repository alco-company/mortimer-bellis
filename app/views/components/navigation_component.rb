
# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::Request

  attr_accessor :items, :license_valid

  def initialize(items: [], root: nil, locale: nil, time_zone: nil, menu: nil)
    @items = items
    @root = root
    @locale = locale
    @time_zone = time_zone
    @menu = menu || default_menu
    @license_valid = Current.get_user.tenant.license_valid?
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
        help_and_shortcuts
      end
    end
  end

  private

    def default_menu
      {
        dashboard: { title: "dashboard", url: "/dashboards/show_dashboard", icon: "home" },
        time_material: { title: "time_material", url: "/time_materials", icon: "time_material" },
        # calendar: { title: "calendar", url: "/calendars", icon: "calendar" },
        # reports: { title: "Reports", url: "/pages", icon: "home" },
        manage: { title: "manage",
          submenu: {
            background_jobs: { title: "background_jobs", url: "/background_jobs", icon: "background_job", license: "super" },
            customers: { title: "customers", url: "/customers", icon: "customer" },
            dashboards: { title: "dashboards", url: "/dashboards", icon: "home", license: "super" },
            filters: { title: "filters", url: "/filters", icon: "filter", license: "super" },
            invoices: { title: "invoices", url: "/invoices", icon: "invoice", license: "super" },
            invoice_items: { title: "invoice_items", url: "/invoice_items", icon: "invoice_item", license: "super" },
            kiosks: { title: "kiosks", url: "/punch_clocks", icon: "punch_clock", license: "super" },
            locations: { title: "locations", url: "/locations", icon: "location", license: "super" },
            products: { title: "products", url: "/products", icon: "product" },
            projects: { title: "projects", url: "/projects", icon: "project", license: "trial ambassador pro" },
            punches: { title: "punches", url: "/punches", icon: "punch", license: "super" },
            # reports: { title: "Reports", url: "/reports", icon: "home" },
            tags: { title: "tags", url: "/tags", icon: "label" },
            tasks: { title: "tasks", url: "/tasks", icon: "task", license: "super" },
            teams: { title: "teams", url: "/teams", icon: "team", license: "trial ambassador pro" },
            tenants: { title: "tenants", url: "/tenants", icon: "tenant", license: "super" },
            provided_services: { title: "integrations", url: "/provided_services", icon: "extension", license: "trial ambassador pro" },
            settings: { title: "settings", url: "/settings", icon: "setting" },
            # oauths: { title: "oauth_applications", url: "/oauth/applications", icon: "oauth" },
            users: { title: "users", url: "/users", icon: "user", license: "trial ambassador pro" }
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
      item[:license] ||= "trial free ambassador essential pro"
      url = item[:url]
      css = "group flex gap-x-3 rounded-md  p-2 text-sm font-semibold leading-6 text-sky-400 hover:text-sky-800 hover:bg-gray-50"
      css = "#{css} #{current_item?(url)}"
      title = item[:title]
      li do
        a(href: url, class: css, data: { action: "click->mobilesidebar#hide" }) do
          render_icon(icon) if icon
          span(class: "", data: { menu_target: "menuitem" }) { t("menu.#{title}") }
        end
      end if Current.user.superadmin? || licensed?(item)
    end

    def expanded_sub?(item)
      item[:submenu].each do |key, i|
        return "rotate-90 text-gray-500" if request.path.split("?")[0].include?(i[:url])
      end
      "text-gray-400"
    end

    def hidden_sub?(item)
      item[:submenu].each do |key, i|
        return "block" if request.path.split("?")[0].include?(i[:url]) && request.path != "/dashboards/show_dashboard"
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
            span(class: "", data: { menu_target: "menuitem" }) { t("menu.#{text}") }
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
      end if Current.user.superadmin? || licensed?(item)
    rescue
    end

    def help_and_shortcuts
      li(class: "fixed bottom-0 bg-linear-to-r from-60% from-white to-90% to-transparent") do
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

    def licensed?(item)
      return false if item[:license] == "super"
      return true if item[:title] == "dashboard"
      return false unless license_valid
      return true if Current.user.tenant.license == "trial"
      return true if item[:submenu]
      item[:license].include? Current.user.tenant.license
    end

    def render_icon(icon, cls = nil)
      cls ||= "h-6 text-sky-300 group-hover:text-sky-600"
      render "Icons::#{icon.camelcase}".constantize.new css: cls
    end
end
