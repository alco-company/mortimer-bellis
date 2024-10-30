# frozen_string_literal: true

class SidebarComponent < ApplicationComponent
  include Phlex::Rails::Helpers::Request

  def initialize(**attribs, &block)
    @menu = attribs[:menu] || default_menu
  end

  def view_template
    div(class: "flex grow flex-col gap-y-5 overflow-y-auto border-r border-gray-200 bg-white px-6") do
      div(class: "flex h-16 shrink-0 items-center") do
        render LogoComponent.new
        button(class: "hidden lg:grid grow w-full justify-items-end", data: { menu_target: "tsb", action: "click->menu#toggleSidebar" }) {
          render Icons::ChevronLeft.new cls: "h-6 w-6 text-gray-400"
        }
      end

      nav(class: "flex flex-1 flex-col") do
        ul(role: "list", class: "flex flex-1 flex-col gap-y-7") do
          li do
            ul(role: "list", class: "-mx-2 space-y-1") do
              @menu.each do |key, item|
                item[:submenu] ? sub_menu(key, item) : menu_item(item: item[:title], url: item[:url], icon: item[:icon])
              end
            end
          end
          settings_and_integrations unless Current.user&.user?
        end
      end
    end
  end

  private

    def default_menu
      {
        dashboard: { title: "dashboard", url: "/", icon: "home" },
        time_material: { title: "time_material", url: "/time_materials", icon: "time_material" },
        calendar: { title: "calendar", url: "/calendars", icon: "calendar", icon: "calendar" },
        # reports: { title: "Reports", url: "/pages", icon: "home" },
        manage: { title: "manage",
          submenu: {
            background_jobs: { title: "background_jobs", url: "/background_jobs", icon: "background_job" },
            customers: { title: "customers", url: "/customers", icon: "customer" },
            dashboards: { title: "dashboards", url: "/dashboards", icon: "home" },
            invoices: { title: "invoices", url: "/invoices", icon: "invoice" },
            invoice_items: { title: "invoice_items", url: "/invoice_items", icon: "invoice_item" },
            kiosks: { title: "kiosks", url: "/punch_clocks", icon: "punch_clock" },
            locations: { title: "locations", url: "/locations", icon: "location" },
            products: { title: "products", url: "/products", icon: "product" },
            projects: { title: "projects", url: "/projects", icon: "project" },
            punches: { title: "punches", url: "/punches", icon: "punch" },
            # reports: { title: "Reports", url: "/reports", icon: "home" },
            teams: { title: "teams", url: "/teams", icon: "team" },
            tenants: { title: "tenants", url: "/tenants", icon: "tenant" },
            users: { title: "users", url: "/users", icon: "user" }
          }
        }
      }
    end

    def current_item?(url)
      return request.path.split("?")[0] == "/" ? "bg-gray-50" : "" if url == "/"
      request.path.split("?")[0].include?(url) ? "bg-gray-50" : ""
    end

    def menu_item(item:, url:, css: "group flex gap-x-3 rounded-md bg-white p-2 text-sm font-semibold leading-6 text-gray-700  hover:bg-gray-50", icon: nil)
      # %(Current: "bg-gray-50", Default: "hover:bg-gray-50")
      css = "#{css} #{current_item?(url)}"
      li do
        a(href: url, class: css, data: { action: "click->menu#closeMobileSidebar" }) do
          render_icon(icon) if icon
          span(class: "", data: { menu_target: "menuitem" }) { I18n.t("menu.#{item}") }
        end
      end
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
              "flex w-full items-center gap-x-3 rounded-md p-2 text-left text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50",
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
              menu_item(item: i[:title], url: i[:url], css: "group flex gap-x-3 rounded-md bg-white p-2 text-sm font-semibold leading-6 text-gray-700  hover:bg-gray-50", icon: i[:icon])
            end
          end
        end
      end
    rescue
    end

    def settings_and_integrations
      li(class: "-mx-6 mt-auto px-6", data: { menu_target: "setting" }) do
        div(class: "flex items-center gap-x-0 ") do
          a(
            href: settings_url,
            class:
              "flex items-center gap-x-1 px-2 py-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-50"
          ) do
            render Icons::Setting.new
          end
          a(
            href: provided_services_url,
            class:
              "flex items-center gap-x-1 px-2 py-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-50"
          ) do
            render Icons::Extension.new
          end
          a(
            href: "https://mortimer.pro/help",
            target: "_blank",
            class:
              "flex items-center gap-x-1 px-2 py-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-50"
          ) do
            render Icons::Help.new cls: "h-6 text-red-500"
          end
        end
      end
    end

    def render_icon(icon)
      render "Icons::#{icon.camelcase}".constantize.new
    end
end
