class WeekComponent < CalendarComponent
  def view_template
    div(class: "flex h-full flex-col") do
      show_header(date)

      div(class: "isolate flex flex-auto flex-col overflow-auto bg-white") do
        div(style: "width:165%", class: "flex max-w-full flex-none flex-col sm:max-w-none md:max-w-full") do
          show_weekday_headers()
          show_time_grid()
        end
      end
    end
  end

  def show_weekday_headers
    wd = %w[ monday tuesday wednesday thursday friday saturday sunday ]
    div(class: "sticky top-0 z-30 flex-none bg-white shadow ring-1 ring-black ring-opacity-5 sm:pr-8") do
      div(class: "grid grid-cols-7 text-sm leading-6 text-gray-500 sm:hidden") do
        (0..6).each do |i|
          dt = date.beginning_of_week
          dt += i.days if i > 0
          button(type: "button", class: "flex flex-col items-center pb-3 pt-2") do
            plain I18n.t("calendar.weekday.#{wd[i]}.firstletter")
            cls = (dt == Date.today) ? "bg-sky-500 text-white" : "text-gray-900"
            span(class: "mt-1 flex h-8 w-8 items-center justify-center font-semibold rounded-full #{cls}") { dt.day }
          end
        end
        # whitespace
        # whitespace
        # button(
        #   type: "button",
        #   class: "flex flex-col items-center pb-3 pt-2"
        # ) do
        #   plain I18n.t("calendar.weekday.tuesday.firstletter")
        #   span(
        #     class:
        #       "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
        #   ) { "11" }
        # end
        # whitespace
        # button(
        #   type: "button",
        #   class: "flex flex-col items-center pb-3 pt-2"
        # ) do
        #   plain  I18n.t("calendar.weekday.wednesday.firstletter")
        #   span(
        #     class:
        #       "mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
        #   ) { "12" }
        # end
        # whitespace
        # button(
        #   type: "button",
        #   class: "flex flex-col items-center pb-3 pt-2"
        # ) do
        #   plain  I18n.t("calendar.weekday.thursday.firstletter")
        #   span(
        #     class:
        #       "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
        #   ) { "13" }
        # end
        # whitespace
        # button(
        #   type: "button",
        #   class: "flex flex-col items-center pb-3 pt-2"
        # ) do
        #   plain  I18n.t("calendar.weekday.friday.firstletter")
        #   span(
        #     class:
        #       "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
        #   ) { "14" }
        # end
        # whitespace
        # button(
        #   type: "button",
        #   class: "flex flex-col items-center pb-3 pt-2"
        # ) do
        #   plain  I18n.t("calendar.weekday.saturday.firstletter")
        #   span(
        #     class:
        #       "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
        #   ) { "15" }
        # end
        # whitespace
        # button(
        #   type: "button",
        #   class: "flex flex-col items-center pb-3 pt-2"
        # ) do
        #   plain  I18n.t("calendar.weekday.sunday.firstletter")
        #   span(
        #     class:
        #       "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
        #   ) { "16" }
        # end
      end
      div(class: "-mr-px hidden grid-cols-7 divide-x divide-gray-100 border-r border-gray-100 text-sm leading-6 text-gray-500 sm:grid") do
        div(class: "col-end-1 w-14")
        (0..6).each do |i|
          dt = date.beginning_of_week
          dt += i.days if i > 0
          div(class: "flex justify-center py-2") do
            cls = (dt == Date.today) ? "text-sky-500" : "text-gray-900"
            div(class: "flex place-items-center #{cls}") do
              plain "%s" % I18n.t("calendar.weekday.#{wd[i]}.short")
              span(class: "pl-1 items-center justify-center font-semibold #{cls}") { dt.day }
            end
          end
        end
        # div(class: "flex items-center justify-center py-3") do
        #   whitespace
        #   span do
        #     plain "Tue "
        #     span(
        #       class:
        #         "items-center justify-center font-semibold text-gray-900"
        #     ) { "11" }
        #   end
        # end
        # div(class: "flex items-center justify-center py-3") do
        #   whitespace
        #   span(class: "flex items-baseline") do
        #     plain "Wed "
        #     span(
        #       class:
        #         "ml-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
        #     ) { "12" }
        #   end
        # end
        # div(class: "flex items-center justify-center py-3") do
        #   whitespace
        #   span do
        #     plain "Thu "
        #     span(
        #       class:
        #         "items-center justify-center font-semibold text-gray-900"
        #     ) { "13" }
        #   end
        # end
        # div(class: "flex items-center justify-center py-3") do
        #   whitespace
        #   span do
        #     plain "Fri "
        #     span(
        #       class:
        #         "items-center justify-center font-semibold text-gray-900"
        #     ) { "14" }
        #   end
        # end
        # div(class: "flex items-center justify-center py-3") do
        #   whitespace
        #   span do
        #     plain "Sat "
        #     span(
        #       class:
        #         "items-center justify-center font-semibold text-gray-900"
        #     ) { "15" }
        #   end
        # end
        # div(class: "flex items-center justify-center py-3") do
        #   whitespace
        #   span do
        #     plain "Sun "
        #     span(
        #       class:
        #         "items-center justify-center font-semibold text-gray-900"
        #     ) { "16" }
        #   end
        # end
      end
    end
  end

  def show_time_grid
    div(class: "flex flex-auto") do
      div(class: "hidden sm:block sticky left-0 z-10 w-14 flex-none ring-1 ring-gray-100")
      div(class: "grid flex-auto grid-cols-1 grid-rows-1") do
        show_horizontal_lines()
        show_vertical_lines()
        show_events()
      end
    end
  end

  #
  # lines every 30 minutes
  #
  def show_horizontal_lines
    whitespace
    comment { "Horizontal lines" }
    div(class: "col-start-1 col-end-2 row-start-1 grid divide-y divide-gray-100", style: "grid-template-rows:repeat(48, minmax(3.5rem, 1fr))") do
      div(class: "row-end-1 h-7 ")
      (0..23).each do |i|
        tm = i < 10 ? "0%d:00" % i : "%d:00" % i
        div do
          div(class: "hidden sm:block sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400") { tm }
        end
        div()
      end

      # div do
      #   div(class: "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400") { "1AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "2AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "3AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "4AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "5AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "6AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "7AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "8AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "9AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "10AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "11AM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "12PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "1PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "2PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "3PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "4PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "5PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "6PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "7PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "8PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "9PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "10PM" }
      # end
      # div
      # div do
      #   div(
      #     class:
      #       "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
      #   ) { "11PM" }
      # end
      # div
    end
  end

  def show_vertical_lines
    div(class: "col-start-1 col-end-2 row-start-1 hidden grid-cols-7 grid-rows-1 divide-x divide-gray-100 sm:grid sm:grid-cols-7") do
      div(class: "col-start-1 row-span-full")
      div(class: "col-start-2 row-span-full")
      div(class: "col-start-3 row-span-full")
      div(class: "col-start-4 row-span-full")
      div(class: "col-start-5 row-span-full")
      div(class: "col-start-6 row-span-full")
      div(class: "col-start-7 row-span-full")
      div(class: "col-start-8 row-span-full w-8")
    end
  end

  #
  # events are display with a 5-minute resolution
  #
  def show_events
    ol(class: "col-start-1 col-end-2 row-start-1 grid grid-cols-7 sm:pr-8", style: "grid-template-rows:1.75rem repeat(288, minmax(0, 1fr)) auto") do
      #
      # col-start-1 = monday
      # grid-row:1 = 00:00
      # /span 5 = 1 hour duration
      # hover:col-start-(x-3) hover:col-span-4 sm:hover:col-span-1 sm:hover:col-start-(x)

      li(class: "relative col-start-4 col-end-5 flex border-violet-600 border-t-2", style: "grid-row:1 /span 1")

      li(class: "relative col-start-1 col-end-3 flex ", style: "grid-row:1 /span 1") do
        a(href: "#", class: "group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-amber-50 p-2 text-xs leading-5 hover:bg-blue-100")
      end

      li(class: "relative col-start-1 flex", style: "grid-row:2 /span 12") do
        a(href: "#", class: "group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-green-50 p-2 text-xs leading-5 hover:bg-blue-100")
      end

      li(class: "relative col-start-2 flex", style: "grid-row:14 /span 6") do
        a(href: "#", class: "group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-blue-50 p-2 text-xs leading-5 hover:bg-blue-100")
      end

      li(class: "relative col-start-3 flex", style: "grid-row:26 /span 6") do
        a(href: "#", class: "group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-blue-50 p-2 text-xs leading-5 hover:bg-blue-100")
      end

      li(
        class: "relative col-start-4 flex hover:col-start-2 hover:col-span-4 sm:hover:col-span-1 sm:hover:col-start-2",
        style: "grid-row:38 /span 16"
      ) do
        a(href: "#", class: "group absolute inset-1 flex flex-col overflow-hidden rounded-md bg-blue-50 p-2 text-xs leading-5 hover:bg-blue-100") do
          p(class: "order-1 font-semibold text-blue-700 truncate") { "Breakfast" }
          p(class: "text-blue-500 group-hover:text-blue-700") do
            time(datetime: "2022-01-12T06:00") { "6:00 AM" }
          end
        end
      end
      li(
        class: "relative mt-px flex sm:col-start-3",
        style: "grid-row:92 /span 30"
      ) do
        whitespace
        a(
          href: "#",
          class:
            "group absolute inset-1 flex flex-col overflow-y-auto rounded-lg bg-pink-50 p-2 text-xs leading-5 hover:bg-pink-100"
        ) do
          p(class: "order-1 font-semibold text-pink-700") do
            "Flight to Paris"
          end
          p(class: "text-pink-500 group-hover:text-pink-700") do
            time(datetime: "2022-01-12T07:30") { "7:30 AM" }
          end
          whitespace
        end
      end
      li(
        class: "relative mt-px hidden sm:col-start-6 sm:flex",
        style: "grid-row:122 /span 24"
      ) do
        whitespace
        a(
          href: "#",
          class:
            "group absolute inset-1 flex flex-col overflow-y-auto rounded-lg bg-gray-100 p-2 text-xs leading-5 hover:bg-gray-200"
        ) do
          p(class: "order-1 font-semibold text-gray-700") do
            "Meeting with design team at Disney"
          end
          p(class: "text-gray-500 group-hover:text-gray-700") do
            time(datetime: "2022-01-15T10:00") { "10:00 AM" }
          end
          whitespace
        end
      end
    end

  end
end
