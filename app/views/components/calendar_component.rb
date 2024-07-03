class CalendarComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_reader :id, :url, :date, :view

  def initialize(id:, url:, date:, view: nil, &block)
    @id = id
    @url = url
    @date = date || Date.current
    @view = view || "month"
  end

  def view_template(&block)
    case view
    when "day"; render DayComponent.new(id: id, url: url, date:, view: view, &block)
    when "week"; render WeekComponent.new(id: id, url: url, date:, view: view, &block)
    when "month"; render MonthComponent.new(id: id, url: url, date:, view: view, &block)
    when "year"; render YearComponent.new(id: id, url: url, date:, view: view, &block)
    end
  end

  def show_header(element)
    header(class: "flex items-center justify-between border-b border-gray-200 px-6 py-4 lg:flex-none") do
      element_caption
      div(class: "flex items-center") do
        period_navigator()
        desktop_view_picker
        mobile_view_picker
      end
    end
  end

  def element_caption
    case view
    when "day"
      div do
        h1(class: "text-base font-semibold leading-6 text-gray-900") do
          time(datetime: I18n.l(date, format: :short_iso), class: "sm:hidden") { I18n.l(date, format: :short) }
          time(datetime: I18n.l(date, format: :short_iso), class: "hidden sm:inline") do
            plain "#{I18n.l(date, format: :short)}"
          end
        end
        p(class: "mt-1 text-sm text-gray-500") { I18n.l(date, format: :day_name) }
      end

    when "week"
      div do
        h1(class: "text-base font-semibold leading-6 text-gray-900") do
          time(datetime: I18n.l(date, format: :short_iso), class: "sm:hidden") { "#{I18n.t("calendar.week.abbr")}" + I18n.l(date, format: :short_week_year) }
          time(datetime: I18n.l(date, format: :short_iso), class: "hidden sm:inline") do
            plain "#{I18n.t("calendar.week.full")} " + I18n.l(date, format: :week_year)
          end
        end
        # p(class: "mt-1 text-sm text-gray-500") { "Saturday" }
      end

    when "month"
      h1(class: "text-base font-semibold leading-6 text-gray-900") do
        time(datetime: I18n.l(date, format: :short_iso)) { I18n.l(date, format: :month_name_year) }
      end

    when "year"
      h1(class: "text-base font-semibold leading-6 text-gray-900") do
        time(datetime: I18n.l(date, format: :short_iso)) { I18n.l(date, format: :year) }
      end

    end
  end

  def period_navigator
    pe, ne = case view
    when "day"
      [ "Previous day", "Next day" ]
    when "week"
      [ "Previous week", "Next week" ]
    when "month"
      [ "Previous month", "Next month" ]
    when "year"
      [ "Previous year", "Next year" ]
    end
    div(class: "relative flex items-center rounded-md bg-white shadow-sm md:items-stretch") do
      button(type: "button", class: "flex h-9 w-12 items-center justify-center rounded-l-md border-y border-l border-gray-300 pr-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pr-0 md:hover:bg-gray-50") do
        span(class: "sr-only") { pe }
        svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
          s.path(fill_rule: "evenodd", d: "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z", clip_rule: "evenodd")
        end
      end
      button(type: "button", class: "hidden border-y border-gray-300 px-3.5 text-sm font-semibold text-gray-900 hover:bg-gray-50 focus:relative md:block") {  I18n.t("calendar.go_today")  }
      span(class: "relative -mx-px h-5 w-px bg-gray-300 md:hidden")
      button(type: "button", class: "flex h-9 w-12 items-center justify-center rounded-r-md border-y border-r border-gray-300 pl-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pl-0 md:hover:bg-gray-50") do
        span(class: "sr-only") { ne }
        svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
          s.path(fill_rule: "evenodd", d: "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z", clip_rule: "evenodd")
        end
      end
    end
  end

  def desktop_view_picker
    lbl = case view
    when "day"; I18n.t("calendar.day_view")
    when "week"; I18n.t("calendar.week_view")
    when "month"; I18n.t("calendar.month_view")
    when "year"; I18n.t("calendar.year_view")
    end
    div(class: "hidden md:ml-4 md:flex md:items-center") do
      div(class: "relative") do
        button(
          type: "button",
          data: { action: "touchstart->calendar#toggleView click->calendar#toggleView click@window->calendar#hideView" },
          class:
            "flex items-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50",
          id: "menu-button",
          aria_expanded: "false",
          aria_haspopup: "true"
        ) do
          plain lbl
          svg(class: "-mr-1 h-5 w-5 text-gray-400", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
            s.path(fill_rule: "evenodd", d: "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z", clip_rule: "evenodd")
          end
        end
        # comment do %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95") end
        div(
          class:
            "hidden absolute right-0 z-10 mt-3 w-36 origin-top-right overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
          role: "menu",
          data: { calendar_target: "view_dropdown" },
          aria_orientation: "vertical",
          aria_labelledby: "menu-button",
          tabindex: "-1"
        ) do
          views_list
        end
      end
      div(class: "ml-6 h-6 w-px bg-gray-300")
      button(
        type: "button",
        class: "mort-btn-primary"
      ) { I18n.t("calendar.create_event") }
    end
  end

  def mobile_view_picker
    div(class: "relative ml-6 md:hidden") do
      button(type: "button", class: "-mx-2 flex items-center rounded-full border border-transparent p-2 text-gray-400 hover:text-gray-500", id: "menu-0-button", aria_expanded: "false", aria_haspopup: "true") do
        span(class: "sr-only") { "Open menu" }
        svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
          s.path(d: "M3 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM8.5 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM15.5 8.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3z")
        end
      end
      # %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      div(class: "absolute right-0 z-10 mt-3 w-36 origin-top-right divide-y divide-gray-100 overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        role: "menu",
        aria_orientation: "vertical",
        aria_labelledby: "menu-0-button",
        tabindex: "-1"
      ) do
        div(class: "py-1", role: "none") do
          # %(Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700")
          a(
            href: "#",
            class: "block px-4 py-2 text-sm text-gray-700",
            role: "menuitem",
            tabindex: "-1",
            id: "menu-0-item-0"
          ) { I18n.t("calendar.create_event") }
        end
        div(class: "py-1", role: "none") do
          a(
            href: "#",
            class: "block px-4 py-2 text-sm text-gray-700",
            role: "menuitem",
            tabindex: "-1",
            id: "menu-0-item-1"
          ) { I18n.t("calendar.go_today") }
        end
        views_list
      end
    end
  end

  def views_list
    div(class: "py-1", role: "none") do
      # comment do %(Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700") end
      a(
        href: "#{url}?view=day",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-2"
      ) { I18n.t("calendar.day_view") }
      a(
        href: "#{url}?view=week",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-3"
      ) { I18n.t("calendar.week_view") }
      a(
        href: "#{url}?view=month",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-4"
      ) { I18n.t("calendar.month_view") }
      a(
        href: "#{url}?view=year",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-5"
      ) { I18n.t("calendar.year_view") }
    end
  end
end
