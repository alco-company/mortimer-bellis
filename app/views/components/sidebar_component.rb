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
        dashboard: { title: "Dashboard", url: "/", icon: "home" },
        time_material: { title: "Time & Material", url: "/time_materials" },
        calendar: { title: "Calendar", url: "/calendars" },
        # reports: { title: "Reports", url: "/pages" },
        manage: { title: "Manage",
          submenu: {
            background_jobs: { title: "BackgroundJobs", url: "/background_jobs" },
            customers: { title: "Customers", url: "/customers" },
            dashboards: { title: "Dashboards", url: "/dashboards" },
            invoices: { title: "Invoices", url: "/invoices" },
            invoice_items: { title: "Invoice Items", url: "/invoice_items" },
            kiosks: { title: "Kiosks", url: "/punch_clocks" },
            locations: { title: "Locations", url: "/locations" },
            products: { title: "Products", url: "/products" },
            projects: { title: "Projects", url: "/projects" },
            punches: { title: "Punches", url: "/punches" },
            # reports: { title: "Reports", url: "/reports" },
            teams: { title: "Teams", url: "/teams" },
            tenants: { title: "Tenants", url: "/tenants" },
            users: { title: "Users", url: "/users" }
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
          plain item.to_s.titleize
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
            plain text
          end
          # comment do
          #   "Expandable link section, show/hide based on state."
          # end
          ul(class: "submenu #{hidden_sub?(item)} mt-1 px-2", id: "sub-menu-1") do
            item[:submenu].each do |key, i|
              next if key == :tenants && !Current.user.superadmin?
              menu_item(item: i[:title], url: i[:url], css: "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50", icon: i[:icon])
            end
          end
        end
      end
    rescue
    end

    def settings_and_integrations
      li(class: "-mx-6 mt-auto") do
        div(class: "flex items-center gap-x-2 pl-10") do
          a(
            href: settings_url,
            class:
              "flex items-center gap-x-4 px-2 py-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-50"
          ) do
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "#5f6368"
            ) do |s|
              s.path(
                d:
                  "m370-80-16-128q-13-5-24.5-12T307-235l-119 50L78-375l103-78q-1-7-1-13.5v-27q0-6.5 1-13.5L78-585l110-190 119 50q11-8 23-15t24-12l16-128h220l16 128q13 5 24.5 12t22.5 15l119-50 110 190-103 78q1 7 1 13.5v27q0 6.5-2 13.5l103 78-110 190-118-50q-11 8-23 15t-24 12L590-80H370Zm70-80h79l14-106q31-8 57.5-23.5T639-327l99 41 39-68-86-65q5-14 7-29.5t2-31.5q0-16-2-31.5t-7-29.5l86-65-39-68-99 42q-22-23-48.5-38.5T533-694l-13-106h-79l-14 106q-31 8-57.5 23.5T321-633l-99-41-39 68 86 64q-5 15-7 30t-2 32q0 16 2 31t7 30l-86 65 39 68 99-42q22 23 48.5 38.5T427-266l13 106Zm42-180q58 0 99-41t41-99q0-58-41-99t-99-41q-59 0-99.5 41T342-480q0 58 40.5 99t99.5 41Zm-2-140Z"
              )
            end
          end
          a(
            href: provided_services_url,
            class:
              "flex items-center gap-x-4 px-2 py-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-50"
          ) do
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "#5f6368"
            ) do |s|
              s.path(
                d:
                  "M352-120H200q-33 0-56.5-23.5T120-200v-152q48 0 84-30.5t36-77.5q0-47-36-77.5T120-568v-152q0-33 23.5-56.5T200-800h160q0-42 29-71t71-29q42 0 71 29t29 71h160q33 0 56.5 23.5T800-720v160q42 0 71 29t29 71q0 42-29 71t-71 29v160q0 33-23.5 56.5T720-120H568q0-50-31.5-85T460-240q-45 0-76.5 35T352-120Zm-152-80h85q24-66 77-93t98-27q45 0 98 27t77 93h85v-240h80q8 0 14-6t6-14q0-8-6-14t-14-6h-80v-240H480v-80q0-8-6-14t-14-6q-8 0-14 6t-6 14v80H200v88q54 20 87 67t33 105q0 57-33 104t-87 68v88Zm260-260Z"
              )
            end
          end
          a(
            href: "https://mortimer.pro/help",
            target: "_blank",
            class:
              "flex items-center gap-x-4 px-2 py-3 text-sm font-semibold leading-6 text-gray-900 hover:bg-gray-50"
          ) do
            svg(
              class: "h-6 w-6 text-red-500",
              xmlns: "http://www.w3.org/2000/svg",
              viewbox: "0 -960 960 960",
              fill: "currentColor",
            ) do |s|
              s.path(
                d:
                  "M480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80ZM364-182l48-110q-42-15-72.5-46.5T292-412l-110 46q23 64 71 112t111 72Zm-72-366q17-42 47.5-73.5T412-668l-46-110q-64 24-112 72t-72 112l110 46Zm188 188q50 0 85-35t35-85q0-50-35-85t-85-35q-50 0-85 35t-35 85q0 50 35 85t85 35Zm116 178q63-24 110.5-71.5T778-364l-110-48q-15 42-46 72.5T550-292l46 110Zm72-368 110-46q-24-63-71.5-110.5T596-778l-46 112q41 15 71 45.5t47 70.5Z"
              )
            end
          end
        end
      end
    end

    def render_icon(icon)
      case icon
      when "home"; render Icons::Home.new
      end
    end
end
