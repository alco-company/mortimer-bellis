class CalendarComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_reader :id, :url, :date, :view, :calendars

  def initialize(id:, url:, date:, calendars: [], view: nil, &block)
    @id = id
    @url = url
    @date = date || Date.current
    @calendars = calendars
    @view = view || "month"
  end

  def view_template(&block)
    case view
    when "day"; render DayComponent.new(id: id, url: url, date: date, calendars: calendars, view: view, &block)
    when "week"; render WeekComponent.new(id: id, url: url, date: date, calendars: calendars, view: view, &block)
    when "month"; render MonthComponent.new(id: id, url: url, date: date, calendars: calendars, view: view, &block)
    when "year"; render YearComponent.new(id: id, url: url, date: date, calendars: calendars, view: view, &block)
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
          time(datetime: I18n.l(date, format: :short_iso), class: "sm:hidden") do
            plain "%s %s" % [ I18n.t("calendar.week_labels.abbr"), I18n.l(date, format: :week_year) ]
          end
          time(datetime: I18n.l(date, format: :short_iso), class: "hidden sm:inline") do
            plain "%s %s" % [ I18n.t("calendar.week_labels.full"), I18n.l(date, format: :week_year) ]
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
    pe_url, pe, ne, ne_url = case view
    when "day"
      [ "#{url}?view=#{view}&date=#{date - 1.day}", I18n.t("calendar.navigation.previous_day"), I18n.t("calendar.navigation.next_day"), "#{url}?view=#{view}&date=#{date + 1.day}" ]
    when "week"
      [ "#{url}?view=#{view}&date=#{date - 7.days}", I18n.t("calendar.navigation.previous_week"), I18n.t("calendar.navigation.next_week"), "#{url}?view=#{view}&date=#{date + 7.days}" ]
    when "month"
      [ "#{url}?view=#{view}&date=#{date - 1.month}", I18n.t("calendar.navigation.previous_month"), I18n.t("calendar.navigation.next_month"), "#{url}?view=#{view}&date=#{date + 1.month}" ]
    when "year"
      [ "#{url}?view=#{view}&date=#{date - 1.year}", I18n.t("calendar.navigation.previous_year"), I18n.t("calendar.navigation.next_year"), "#{url}?view=#{view}&date=#{date + 1.year}" ]
    end
    div(class: "relative flex items-center rounded-md bg-white shadow-sm md:items-stretch") do
      link_to(pe_url, class: "flex h-9 w-12 items-center justify-center rounded-l-md border-y border-l border-gray-300 pr-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pr-0 md:hover:bg-gray-50") do
        span(class: "sr-only") { pe }
        svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
          s.path(fill_rule: "evenodd", d: "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z", clip_rule: "evenodd")
        end
      end
      link_to("#{url}?view=#{view}&date=#{Date.today}", class: "hidden border-y border-gray-300 px-3.5 pt-1.5 text-sm font-semibold text-gray-900 hover:bg-gray-50 focus:relative md:block") {  I18n.t("calendar.go_today")  }
      span(class: "relative -mx-px h-5 w-px bg-gray-300 md:hidden")
      link_to(ne_url, class: "flex h-9 w-12 items-center justify-center rounded-r-md border-y border-r border-gray-300 pl-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pl-0 md:hover:bg-gray-50") do
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
      link_to(
        helpers.new_modal_url(id: id, modal_form: "event", resource_class: "event", step: "new", view: view),
        data: { turbo_stream: true },
        # link_to helpers.delete_all_url(),
        # data: { turbo_method: :delete, turbo_confirm: "Are you sure?", turbo_stream: true, action: "click->contextmenu#hide" },
        class: "mort-btn-primary",
        role: "menuitem",
        tabindex: "-1") do
        plain I18n.t("calendar.create_event")
      end
    end
  end

  def mobile_view_picker
    div(class: "relative ml-6 md:hidden") do
      button(type: "button",
        data: { action: "touchstart->calendar#toggleMobileView click->calendar#toggleMobileView click@window->calendar#hideMobileView" },
        class: "-mx-2 flex items-center rounded-full border border-transparent p-2 text-gray-400 hover:text-gray-500",
        id: "menu-0-button",
        aria_expanded: "false",
        aria_haspopup: "true") do
        span(class: "sr-only") { "Open menu" }
        svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
          s.path(d: "M3 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM8.5 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM15.5 8.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3z")
        end
      end
      # %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      div(class: "hidden absolute right-0 z-10 mt-3 w-36 origin-top-right divide-y divide-gray-100 overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        role: "menu",
        data: { calendar_target: "mobile_view_dropdown" },
        aria_orientation: "vertical",
        aria_labelledby: "menu-0-button",
        tabindex: "-1"
      ) do
        div(class: "py-1", role: "none") do
          link_to(
            helpers.new_modal_url(id: id, modal_form: "event", resource_class: "event", step: "new"),
            data: { turbo_stream: true },
            # link_to helpers.delete_all_url(),
            # data: { turbo_method: :delete, turbo_confirm: "Are you sure?", turbo_stream: true, action: "click->contextmenu#hide" },
            class: "block px-4 py-2 text-sm text-gray-700",
            role: "menuitem",
            tabindex: "-1") do
            plain I18n.t("calendar.create_event")
          end
          # %(Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700")
          # a(
          #   href: "#",
          #   class: "block px-4 py-2 text-sm text-gray-700",
          #   role: "menuitem",
          #   tabindex: "-1",
          #   id: "menu-0-item-0"
          # ) { I18n.t("calendar.create_event") }
        end
        div(class: "py-1", role: "none") do
          link_to("#{url}?view=#{view}&date=#{Date.today}",
            class: "block px-4 py-2 text-sm text-gray-700",
            role: "menuitem",
            tabindex: "-1",
            id: "menu-0-item-1") do
              I18n.t("calendar.go_today")
          end
        end
        views_list
      end
    end
  end

  def views_list
    div(class: "py-1", role: "none") do
      # comment do %(Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700") end
      a(
        href: "#{url}?view=day&date=#{date}",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-2"
      ) { I18n.t("calendar.day_view") }
      a(
        href: "#{url}?view=week&date=#{date}",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-3"
      ) { I18n.t("calendar.week_view") }
      a(
        href: "#{url}?view=month&date=#{date}",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-4"
      ) { I18n.t("calendar.month_view") }
      a(
        href: "#{url}?view=year&date=#{date}",
        class: "block px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        id: "menu-0-item-5"
      ) { I18n.t("calendar.year_view") }
    end
  end

  def show_weekday_headers(cls = "")
    wd = %w[ monday tuesday wednesday thursday friday saturday sunday ]
    div(class: "sticky top-0 z-30 flex-none bg-white shadow ring-1 ring-black ring-opacity-5 sm:pr-8 #{cls}") do
      div(class: "grid grid-cols-7 text-sm leading-6 text-gray-500 sm:hidden") do
        (0..6).each do |i|
          dt = date.beginning_of_week
          dt += i.days if i > 0
          link_to(
            helpers.new_modal_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", date: I18n.l(dt, format: :short_iso)),
            data: { turbo_stream: true },
            class: "flex flex-col items-center pb-3 pt-2",
            role: "menuitem",
            tabindex: "-1") do
            plain I18n.t("calendar.weekday.#{wd[i]}.firstletter")
            cls = (dt == Date.today) ? "bg-sky-500 text-white" : "text-gray-900"
            span(class: "mt-1 flex h-8 w-8 items-center justify-center font-semibold rounded-full #{cls}") { dt.day }
            span(class: "sr-only") do
              plain "datetime: #{I18n.l(dt, format: :short_iso)} "
              plain "day summary"
            end
          end
        end
      end
      div(class: "-mr-px hidden grid-cols-7 divide-x divide-gray-100 border-r border-gray-100 text-sm leading-6 text-gray-500 sm:grid") do
        div(class: "col-end-1 w-14")
        (0..6).each do |i|
          dt = date.beginning_of_week
          dt += i.days if i > 0
          link_to(
            helpers.new_modal_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", date: I18n.l(dt, format: :short_iso)),
            data: { turbo_stream: true },
            class: "flex justify-center py-2",
            role: "menuitem",
            tabindex: "-1") do
            cls = (dt == Date.today) ? "text-sky-500" : "text-gray-900"
            div(class: "flex place-items-center #{cls}") do
              plain "%s" % I18n.t("calendar.weekday.#{wd[i]}.short")
              span(class: "pl-1 items-center justify-center font-semibold #{cls}") { dt.day }
              span(class: "sr-only") do
                plain "datetime: #{I18n.l(dt, format: :short_iso)} "
                plain "day summary"
              end
            end
          end
        end
      end
    end
  end

  #
  # lines every 30 minutes
  #
  def show_horizontal_lines(cls = "")
    div(class: "col-start-1 col-end-2 row-start-1 grid divide-y divide-gray-100", style: "grid-template-rows:repeat(48, minmax(3.5rem, 1fr))") do
      div(class: "row-end-1 h-7 ")
      (0..23).each do |i|
        tm = i < 10 ? "0%d:00" % i : "%d:00" % i
        div do
          div(class: "#{cls} sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400") { tm }
        end
        div()
      end
    end
  end

  #
  # events are display with a 5-minute resolution
  #
  def show_events_on_day_and_week(window, cls = "")
    ol(class: "col-start-1 col-end-2 row-start-1 grid #{cls}", style: "grid-template-rows:1.75rem repeat(288, minmax(0, 1fr)) auto") do
      #
      # col-start-1 = monday
      # grid-row:1 = 00:00
      # /span 5 = 1 hour duration
      # hover:col-start-(x-3) hover:col-span-4 sm:hover:col-span-1 sm:hover:col-start-(x)

      # holiday marker
      # li(class: "relative col-start-4 col-end-5 flex border-violet-600 border-t-2", style: "grid-row:1 /span 1")
      (window[:from].to_date..window[:to].to_date).each_with_index do |dt, index|
        holiday?(dt) ?
          li(class: "relative col-start-#{index+1} flex border-violet-600 border-t-2", style: "grid-row:1 /span 1") :
          {}
      end

      # punches
      (window[:from].to_date..window[:to].to_date).each_with_index do |dt, index|
        punches?(dt, :day_week, index, window)
      end

      #  events
      calendar_events do |event, tz|
        (window[:from].to_date..window[:to].to_date).each_with_index do |dt, index|
          if event.occurs?(window, dt, tz)
            if event.all_day?
              li(class: "relative col-start-#{index+1} flex ", style: "grid-row:1 /span 1") do
                link_to(
                  helpers.new_modal_url(id: event.id, modal_form: "event", resource_class: "event", step: "edit", view: view, date: date),
                  data: { turbo_stream: true },
                  class: "#{event.event_color} border group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-amber-50 pl-2 text-amber-500 text-xs hover:bg-amber-100",
                  role: "menuitem",
                  tabindex: "-1") do
                  plain event.name
                end
              end
            else
              if event.from_date < dt && event.event_metum.nil?
                start = 0
              else
                start = event.from_time.hour * 12 + event.from_time.min / 5
              end
              if event.to_date > dt && event.event_metum.nil?
                duration = 288 - start
              else
                duration = (event.to_time.hour * 12 + event.to_time.min / 5) - start
              end
              cls = duration < 12 ? "hidden" : ""
              li(class: "relative col-start-#{index+1} flex ", style: "grid-row:#{start + 2} /span #{duration}") do
                link_to(
                  helpers.new_modal_url(id: event.id, modal_form: "event", resource_class: "event", step: "edit", view: view, date: date),
                  data: { turbo_stream: true },
                  class: "#{event.event_color} border group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-blue-50 pl-2 text-blue-500 text-xs hover:bg-blue-100",
                  role: "menuitem",
                  tabindex: "-1") do
                  p(class: "order-1 font-semibold text-blue-700 truncate") { event.name }
                  p(class: "text-blue-500 group-hover:text-blue-700 #{cls}") do
                    time(datetime: Time.new(dt.year, dt.month, dt.day, event.from_time.hour, event.from_time.min)) { "%02d:%02d" % [ event.from_time.hour, event.from_time.min ] }
                  end
                end
              end
            end
          end
        end
      end

      # making sure the OL returns at least one LI element
      li { }
    end
  end

  def month_component(month, show_navigation = false)
    from_date = Date.new(date.year, month, 1)
    section(class: "text-center") do
      if show_navigation
        pl, pt, nt, nl = [ "#{url}?view=#{view}&date=#{date - 1.month}", I18n.t("calendar.navigation.previous_month"), I18n.t("calendar.navigation.next_month"), "#{url}?view=#{view}&date=#{date + 1.month}" ]
        div(class: "flex items-center text-center text-gray-900") do
          link_to(pl, class: "-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500") do
            span(class: "sr-only") { pt }
            svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
              s.path(fill_rule: "evenodd", d: "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z", clip_rule: "evenodd")
            end
          end
          div(class: "flex-auto text-sm font-semibold") { I18n.l(from_date, format: :month_name_year) }
          link_to(nl, class: "-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500") do
            span(class: "sr-only") { nt }
            svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor", aria_hidden: "true") do |s|
              s.path(fill_rule: "evenodd", d: "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z", clip_rule: "evenodd")
            end
          end
        end
      else
        h2(class: "text-sm font-semibold text-gray-900") { I18n.l(from_date, format: :month_name) }
      end
      dt = Date.new(date.year, month, 1).at_beginning_of_week
      weekday_header
      div(class: "isolate mt-2 grid grid-cols-7 gap-px rounded-lg bg-gray-200 text-sm shadow ring-1 ring-gray-200") do
        # Always include: "py-1.5 hover:bg-gray-100 focus:z-10"
        # Is current month, include: "bg-white text-gray-900"
        # Is not current month, include: "bg-gray-50 text-gray-400"
        #
        # Top left day, include: "rounded-tl-lg"
        # Top right day, include: "rounded-tr-lg"
        # Bottom left day, include: "rounded-bl-lg"
        # Bottom right day, include: "rounded-br-lg")
        #
        #  1  2  3  4  5  6  7
        #  8  9 10 11 12 13 14
        # 15 16 17 18 19 20 21
        # 22 23 24 25 26 27 28
        # 29 30 31  1  2  3  4
        #  5  6  7  8  9 10 11
        (0..41).each do |day|
          dt += 1.days if day > 0
          cls = case day
          when 0; "rounded-tl-lg"
          when 6; "rounded-tr-lg"
          when 35; "rounded-bl-lg"
          when 41; "rounded-br-lg"
          else; ""
          end
          cls += (dt.month == from_date.month) ? " bg-white text-gray-900" : " bg-gray-50 text-gray-400"
          cls += holiday?(dt) ? " bg-violet-100" : ""
          # button(type: "button",
          #   data: { action: "click->calendar#showDaySummary", date: I18n.l(dt, format: :short_iso) },
          #   class: "#{cls} bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10") do
          #   # Always include: "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #   # Is today, include: "bg-indigo-600 font-semibold text-white")
          #   cls = (dt == Date.today && (dt.month == from_date.month)) ? "bg-sky-600 font-semibold text-white" : ""
          #   time(datetime: I18n.l(dt, format: :short_iso), class: "#{cls} mx-auto flex h-7 w-7 items-center justify-center rounded-full") { dt.day }
          # end
          # div(class: "h-7 w-7") { dt.day }
          link_to(
            helpers.new_modal_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", view: view, date: I18n.l(dt, format: :short_iso)),
            data: { turbo_stream: true },
            class: "#{cls} relative bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10",
            role: "menuitem",
            tabindex: "-1") do
              cls = (dt == Date.today && (dt.month == from_date.month)) ? "bg-sky-600 font-semibold text-white" : ""
              time(datetime: I18n.l(dt, format: :short_iso), class: " #{cls} mx-auto flex flex-col h-7 w-7 items-center justify-center rounded-full") do
                span { dt.day }
                div(class: "absolute bottom-0") do
                  events?(dt, :year, { from: dt.beginning_of_month.to_time, to: dt.end_of_month.to_time })
                  punches?(dt, :year, 0, { from: dt.beginning_of_month.to_time, to: dt.end_of_month.to_time })
                end
              end
              span(class: "sr-only") do
                plain "datetime: #{I18n.l(dt, format: :short_iso)} "
                plain "day summary"
              end
          end
        end
      end
    end
  end

  def weekday_header
    div(class: "mt-6 grid grid-cols-7 text-xs leading-6 text-gray-500") do
      div { I18n.t("calendar.weekday.monday.firstletter") }
      div { I18n.t("calendar.weekday.tuesday.firstletter") }
      div { I18n.t("calendar.weekday.wednesday.firstletter") }
      div { I18n.t("calendar.weekday.thursday.firstletter") }
      div { I18n.t("calendar.weekday.friday.firstletter") }
      div { I18n.t("calendar.weekday.saturday.firstletter") }
      div { I18n.t("calendar.weekday.sunday.firstletter") }
    end
  end


  def holiday?(dt)
    Holiday.today? dt
  end

  def week_number(day, dt, cls = "")
    case day
    when 0;   div(class: "#{cls} text-gray-300") { I18n.l(dt, format: :week_number) }
    when 7;   div(class: "#{cls} text-gray-300") { I18n.l(dt, format: :week_number) }
    when 14;  div(class: "#{cls} text-gray-300") { I18n.l(dt, format: :week_number) }
    when 21;  div(class: "#{cls} text-gray-300") { I18n.l(dt, format: :week_number) }
    when 28;  div(class: "#{cls} text-gray-300") { I18n.l(dt, format: :week_number) }
    when 35;  div(class: "#{cls} text-gray-300") { I18n.l(dt, format: :week_number) }
    else;     div(class: "h-6") { " " }
    end
  end

  def all_day_events(dt, cls = "")
    unless any_calendars?
      div(class: "pr-1.5 #{cls}") { " " }
    else
      hits = 0
      calendar_events do |event|
        if event.all_day? && event.from_date.to_date == dt
          hits += 1
          div(class: "#{event.event_color} text-amber-500 font-extrabold justify-self-end text-sm pr-1.5 #{cls}") { "!" }
        end
      end
      div(class: "pr-1.5 #{cls}") { " " } if hits.zero?
    end
  end

  def punches?(dt, view, index, window)
    # punch_cards.flatten.select { |p| p.work_date == dt }.any? ?
    #   div(class: "text-sky-500 font-bold justify-self-start text-xl #{cls}") { "|" } :
    #   div() { " " }
    from_ats = []
    hits = 0
    calendar_punches(window) do |punch|
      if punch.punched_at.to_date == dt
        from_at = punch.punched_at.hour * 12 + punch.punched_at.min / 5
        from_at += 2 if from_ats.include? from_at
        from_ats.push(from_at)
        case view
        when :day_week; list_punch_item(index, dt, punch, from_at)
        when :month; hits += 1
        when :year; hits += 1
        end
      end
    end
    span(class: "font-extrabold place-self-center col-span-2 text-2xl text-blue-500") { "." } if hits > 0 && view == :month
    span(class: "text-xs text-blue-500") { "." } if hits > 0 && view == :year
  end

  def list_punch_item(i, dt, punch, from_at)
    punch_color = case true
    when punch.in?; "text-green-500"
    when punch.out?; "text-blue-500"
    when punch.break?; "text-amber-500"
    else; "text-gray-500"
    end
    li(class: "relative col-start-#{i+1} flex", style: "grid-row:#{from_at + 2} /span 2") do
      div(href: "#", class: "absolute flex flex-col overflow-hidden text-md ") do
        link_to(helpers.modal_url(id: punch.id, modal_form: "punch", resource_class: "punch", step: "view"), data: { turbo_stream: true }) do
          svg(
            class: "pr-1 #{punch_color}  h-6 w-6 ml-2",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            stroke: "currentColor",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "M200-80q-33 0-56.5-23.5T120-160v-480q0-33 23.5-56.5T200-720h40v-200h480v200h40q33 0 56.5 23.5T840-640v480q0 33-23.5 56.5T760-80H200Zm120-640h320v-120H320v120ZM200-160h560v-480H200v480Zm280-40q83 0 141.5-58.5T680-400q0-83-58.5-141.5T480-600q-83 0-141.5 58.5T280-400q0 83 58.5 141.5T480-200Zm0-60q-58 0-99-41t-41-99q0-58 41-99t99-41q58 0 99 41t41 99q0 58-41 99t-99 41Zm46-66 28-28-54-54v-92h-40v108l66 66Zm-46-74Z"
            )
          end
        end
      end
    end
  end

  # def punch_cards(rg = nil)
  #   return @punch_cards if rg.nil?
  #   @punch_cards = calendars.collect { |c| c.punch_cards(rg) }
  # end

  def events?(dt, view, window = nil, cls = "")
    unless any_calendars?
      div() { " " }
    else
      calendar_events do |event, tz|
        if event.occurs?(window, dt, tz)
          case view
          # when :day;   hits = 1
          # when :week;  hits = 2
          when :month; span(class: "font-extrabold place-self-center col-span-2 text-2xl #{cls}") { "." }
          when :year;  span(class: "text-xs text-gray-500") { "." }
          end
          return
        end
      end
      div() { " " }
    end
  end

  def any_calendars?
    calendars.any?
  end

  def calendar_events
    calendars.each do |calendar|
      tz = calendar.time_zone
      calendar.events.each do |event|
        yield event, tz
      end
    end
  end

  def calendar_punches(window, &block)
    calendars.each do |calendar|
      if calendar.calendarable_type == "User"
        calendar.calendarable.punch_cards.windowed(window).map(&:punches).flatten.each do |punch|
          yield punch
        end
      end
    end
  end
end
