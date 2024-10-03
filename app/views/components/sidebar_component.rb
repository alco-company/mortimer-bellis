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
                item[:submenu] ? sub_menu(key, item) : menu_item(item[:title], item[:url])
              end
            end
          end
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
            end
          end
        end
        whitespace
      end
    end
  end

  private

    def default_menu
      {
        dashboard: { title: "Dashboard", url: "/" },
        time: { title: "Time", url: "/punches" },
        calendar: { title: "Calendar", url: "/calendars" },
        reports: { title: "Reports", url: "/pages" },
        manage: { title: "Manage",
          submenu: {
            punches: { title: "Punches", url: "/punches" },
            users: { title: "Users", url: "/users" },
            teams: { title: "Teams", url: "/teams" },
            kiosks: { title: "Kiosks", url: "/punch_clocks" },
            locations: { title: "Locations", url: "/locations" },
            reports: { title: "Reports", url: "/reports" },
            dashboards: { title: "Dashboards", url: "/dashboards" }
          }
        }
      }
    end

    def current_item?(url)
      return request.path.split("?")[0] == "/" ? "bg-gray-50" : "" if url == "/"
      request.path.split("?")[0].include?(url) ? "bg-gray-50" : ""
    end

    def menu_item(text, url, css = "block rounded-md hover:bg-gray-50 py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 truncate")
      # %(Current: "bg-gray-50", Default: "hover:bg-gray-50")
      css = "#{css} #{current_item?(url)}"
      li do
        a(href: url, class: css, data: { action: "click->menu#closeMobileSidebar" }) { text.to_s.titleize }
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
            comment do
              %(Expanded: "rotate-90 text-gray-500", Collapsed: "text-gray-400")
            end
            svg(
              class: "h-5 w-5 shrink-0 #{expanded_sub?(item)}",
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
          whitespace
          comment do
            "Expandable link section, show/hide based on state."
          end
          ul(class: "submenu #{hidden_sub?(item)} mt-1 px-2", id: "sub-menu-1") do
            item[:submenu].each do |key, i|
              menu_item(i[:title], i[:url], "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50")
            end
          end
        end
      end
    end
end
