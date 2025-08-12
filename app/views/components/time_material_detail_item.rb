class TimeMaterialDetailItem < ApplicationComponent
  attr_reader :item, :id

  def initialize(item:, id: nil, links: [])
    @item = item
    @id = id
    @links = links
  end

  def view_template
    li(id: @id, class: "relative flex justify-between gap-x-6 px-4 py-5 hover:bg-gray-50 sm:px-6") do
      div(class: "flex min-w-0 gap-x-4") do
        img(class: "h-12 w-12 flex-none rounded-full bg-gray-50", src: item.mugshot, alt: "") if item.has_mugshot?
        div(class: "min-w-0 flex-auto") do
          p(class: "text-sm font-semibold leading-2 text-gray-900") do
            a(href: "#") do
              span(class: "absolute inset-x-0 -top-px bottom-0")
              plain item.about
            end
          end
          div(class: "mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500") do
            time_material_state "sm:hidden "

            customer_name "whitespace-nowrap sm:hidden"
            svg_circle
            p(class: "truncate") { t("time_materials.list.time_logged", time: @item.time) }
            svg_circle
            logged_date
          end
        end
      end

      div(class: "flex shrink-0 items-center gap-x-4") do
        div(class: "hidden sm:flex sm:flex-col sm:items-end") do
          customer_name "mt-1 flex text-xs leading-5 text-gray-500"
          time_material_state
        end
        render Contextmenu.new resource: item, turbo_frame: "form", alter: true, links: @links, cls: "relative flex-none"
        # div(class: "relative flex-none") do
        #   whitespace
        #   button(
        #     type: "button",
        #     class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
        #     aria_expanded: "false",
        #     aria_haspopup: "true"
        #   ) do
        #     whitespace
        #     span(class: "sr-only") { "Open options" }
        #     whitespace
        #     svg(
        #       class: "h-5 w-5",
        #       viewbox: "0 0 20 20",
        #       fill: "currentColor"
        #     ) do |s|
        #       s.path(
        #         d:
        #           "M10 3a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM10 8.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM11.5 15.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0Z"
        #       )
        #     end
        #     whitespace
        #   end
        #   whitespace
        #   comment { "Dropdown menu" }
        #   div(
        #     data_contextmenu_target: "popup",
        #     class:
        #       "hidden absolute right-0 z-10 mt-2 w-auto min-w-18 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-hidden",
        #     role: "menu",
        #     aria_orientation: "vertical",
        #     aria_labelledby: "options-menu-0-button",
        #     tabindex: "-1"
        #   ) do
        #     whitespace
        #     comment do
        #       "Active: &quot;bg-gray-50&quot;, Not Active: &quot;&quot;"
        #     end
        #     whitespace
        #     a(
        #       class:
        #         "block p-3 lg:px-3 lg:py-1 text-sm leading-6 text-gray-900",
        #       role: "menuitem",
        #       data_turbo_action: "advance",
        #       data_turbo_frame: "form",
        #       tabindex: "-1",
        #       href: "https://localhost:3000/teams/2/edit"
        #     ) do
        #       plain " Redigér "
        #       span(class: "sr-only") { ", Team 2" }
        #       whitespace
        #     end
        #     whitespace
        #     a(
        #       data_turbo_stream: "true",
        #       class:
        #         "block p-3 lg:px-3 lg:py-1 text-sm leading-6 text-gray-200",
        #       role: "deleteitem",
        #       tabindex: "-1",
        #       href:
        #         "https://localhost:3000/modal/new?id=2&modal_form=delete&modal_next_step=accept&resource_class=team&url=https%3A%2F%2Flocalhost%3A3000%2Fteams%2F2"
        #     ) do
        #       plain " Slet "
        #       span(class: "sr-only") { ", Team 2" }
        #       whitespace
        #     end
        #     whitespace
        #     a(
        #       class:
        #         "block p-3 lg:px-3 lg:py-1 text-sm leading-6 text-gray-900",
        #       role: "menuitem",
        #       data_turbo_action: "advance",
        #       data_turbo_frame: "form",
        #       tabindex: "-1",
        #       href: "https://localhost:3000/teams/2/edit"
        #     ) do
        #       plain " Fakturér "
        #       span(class: "sr-only") { ", Team 2" }
        #       whitespace
        #     end
        #     whitespace
        #     a(
        #       class:
        #         "block p-3 lg:px-3 lg:py-1 text-sm leading-6 text-gray-900",
        #       role: "menuitem",
        #       data_turbo_action: "advance",
        #       data_turbo_frame: "form",
        #       tabindex: "-1",
        #       href: "https://localhost:3000/teams/2/edit"
        #     ) do
        #       plain " Delegér "
        #       span(class: "sr-only") { ", Team 2" }
        #       whitespace
        #     end
        #     whitespace
        #     a(
        #       class:
        #         "block p-3 lg:px-3 lg:py-1 text-sm leading-6 text-gray-900",
        #       role: "menuitem",
        #       data_turbo_action: "advance",
        #       data_turbo_frame: "form",
        #       tabindex: "-1",
        #       href: "https://localhost:3000/teams/2/edit"
        #     ) do
        #       plain " Vælg "
        #       span(class: "sr-only") { ", Team 2" }
        #       whitespace
        #     end
        #   end
        # end
      end
    end
    # li(
    #   class:
    #     "flex items-center justify-between gap-x-6 px-3 py-5 bg-gray-100"
    # ) do
    #   div(class: "min-w-0") do
    #     div(class: "flex items-start gap-x-3") do
    #       p(class: "text-sm font-semibold leading-6 text-gray-900") do
    #         "Purchased Hardware"
    #       end
    #       p(
    #         class:
    #           "mt-0.5 whitespace-nowrap rounded-md bg-green-700 px-1.5 py-0.5 text-green-50 text-xs font-medium ring-1 ring-inset ring-gray-500/10"
    #       ) { "Billed" }
    #     end
    #     div(
    #       class:
    #         "mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500"
    #     ) do
    #       p(class: "truncate") { "$300.00 spent" }
    #       whitespace
    #       svg(
    #         viewbox: "0 0 2 2",
    #         class: "h-0.5 w-0.5 fill-current"
    #       ) { |s| s.circle(cx: "1", cy: "1", r: "1") }
    #       p(class: "whitespace-nowrap") do
    #         whitespace
    #         time(datetime: "2024-10-06") { "2024-10-06" }
    #       end
    #     end
    #   end
    #   div(class: "flex flex-none items-center gap-x-4") do
    #     whitespace
    #     a(
    #       href: "#",
    #       class:
    #         "hidden rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:block"
    #     ) do
    #       plain "View details"
    #       span(class: "sr-only") { ", Purchased Hardware" }
    #     end
    #     div(class: "relative flex-none") do
    #       whitespace
    #       button(
    #         type: "button",
    #         class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
    #         aria_expanded: "false",
    #         aria_haspopup: "true"
    #       ) do
    #         whitespace
    #         span(class: "sr-only") { "Open options" }
    #         whitespace
    #         svg(
    #           class: "h-5 w-5",
    #           viewbox: "0 0 20 20",
    #           fill: "currentColor"
    #         ) do |s|
    #           s.path(
    #             d:
    #               "M10 3a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM10 8.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM11.5 15.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0Z"
    #           )
    #         end
    #         whitespace
    #       end
    #       whitespace
    #       comment { "Dropdown menu" }
    #     end
    #   end
    # end
    # whitespace
    # comment { "Example Material Entry" }
    # li(class: "flex items-center justify-between gap-x-6 px-3 py-5") do
    #   div(class: "min-w-0") do
    #     div(class: "flex items-start gap-x-3") do
    #       p(class: "text-sm font-semibold leading-6 text-gray-900") do
    #         "Purchased Hardware"
    #       end
    #       p(
    #         class:
    #           "mt-0.5 whitespace-nowrap rounded-md bg-gray-50 px-1.5 py-0.5 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10"
    #       ) { "Non-billable" }
    #     end
    #     div(
    #       class:
    #         "mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500"
    #     ) do
    #       p(class: "truncate") { "$300.00 spent" }
    #       whitespace
    #       svg(
    #         viewbox: "0 0 2 2",
    #         class: "h-0.5 w-0.5 fill-current"
    #       ) { |s| s.circle(cx: "1", cy: "1", r: "1") }
    #       p(class: "whitespace-nowrap") do
    #         whitespace
    #         time(datetime: "2024-10-06") { "2024-10-06" }
    #       end
    #     end
    #   end
    #   div(class: "flex flex-none items-center gap-x-4") do
    #     whitespace
    #     a(
    #       href: "#",
    #       class:
    #         "hidden rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:block"
    #     ) do
    #       plain "View details"
    #       span(class: "sr-only") { ", Purchased Hardware" }
    #     end
    #     div(class: "relative flex-none") do
    #       whitespace
    #       button(
    #         type: "button",
    #         class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
    #         aria_expanded: "false",
    #         aria_haspopup: "true"
    #       ) do
    #         whitespace
    #         span(class: "sr-only") { "Open options" }
    #         whitespace
    #         svg(
    #           class: "h-5 w-5",
    #           viewbox: "0 0 20 20",
    #           fill: "currentColor"
    #         ) do |s|
    #           s.path(
    #             d:
    #               "M10 3a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM10 8.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM11.5 15.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0Z"
    #           )
    #         end
    #         whitespace
    #       end
    #       whitespace
    #       comment { "Dropdown menu" }
    #     end
    #   end
    # end
    # whitespace
    # comment { "Example Time Active Entry" }
    # li(
    #   class:
    #     "flex items-center justify-between bg-green-100 px-3 gap-x-6 py-4"
    # ) do
    #   div(class: "min-w-0") do
    #     div(class: "flex items-start gap-x-3") do
    #       p(class: "text-sm font-semibold text-gray-900 truncate") do
    #         "Fixing running wild firewall - with way too much text in the about"
    #       end
    #       p(
    #         class:
    #           "mt-0.5 whitespace-nowrap rounded-md bg-green-50 px-1.5 py-0.5 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
    #       ) { "Billable" }
    #     end
    #     div(
    #       class: "mt-1 flex items-center gap-x-2 text-xs text-gray-500"
    #     ) do
    #       p(class: "whitespace-nowrap text-sky-600") { "Randers Tegl" }
    #       whitespace
    #       svg(
    #         viewbox: "0 0 2 2",
    #         class: "h-0.5 w-0.5 fill-current"
    #       ) { |s| s.circle(cx: "1", cy: "1", r: "1") }
    #       p(class: "truncate") { "23 minutes logged" }
    #     end
    #     div(
    #       class: "mt-1 flex items-center gap-x-2 text-xs text-gray-500"
    #     ) do
    #       p(class: "truncate") { "3 pauses" }
    #       whitespace
    #       svg(
    #         viewbox: "0 0 2 2",
    #         class: "h-0.5 w-0.5 fill-current"
    #       ) { |s| s.circle(cx: "1", cy: "1", r: "1") }
    #       p(class: "truncate") { "paused 2024-10-08 11:07" }
    #     end
    #   end
    #   div(class: "flex flex-none items-center gap-x-4") do
    #     whitespace
    #     a(
    #       href: "#",
    #       class:
    #         "hidden rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:block"
    #     ) do
    #       plain "View details"
    #       span(class: "sr-only") { ", Purchased Hardware" }
    #     end
    #     div(class: "relative flex-none") do
    #       whitespace
    #       button(
    #         type: "button",
    #         class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
    #         aria_expanded: "false",
    #         aria_haspopup: "true"
    #       ) do
    #         whitespace
    #         span(class: "sr-only") { "Open options" }
    #         whitespace
    #         svg(
    #           class: "h-5 w-5",
    #           viewbox: "0 0 20 20",
    #           fill: "currentColor"
    #         ) do |s|
    #           s.path(
    #             d:
    #               "M10 3a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM10 8.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM11.5 15.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0Z"
    #           )
    #         end
    #         whitespace
    #       end
    #       whitespace
    #       comment { "Dropdown menu" }
    #     end
    #   end
    # end
  end
  def customer_name(cls)
    if @item.customer
      span(class: cls) do
        a(
          href: "mailto:leslie.alexander@example.com",
          class: "mort-link-primary text-sm relative truncate hover:underline"
        ) { @item.customer.name }
        whitespace
      end
    else
      span(class: cls) { @item.customer_name }
    end
  end

  def logged_date
    return if @item.date.blank?
    time(class: "hidden xs:inline", datetime: @item.date) do
      @item.date
    end
  end

  def time_material_state(cls = "")
    span(class: "mt-0.5 #{cls} whitespace-nowrap rounded-md bg-green-700 px-1.5 py-0.5 text-green-50 text-xs font-medium ring-1 ring-inset ring-gray-500/10") { "Billed" }
  end

  def svg_circle
    svg(
      viewbox: "0 0 2 2",
      class: "sm:hidden h-0.5 w-0.5 fill-current"
    ) { |s| s.circle(cx: "1", cy: "1", r: "1") }
  end
end
