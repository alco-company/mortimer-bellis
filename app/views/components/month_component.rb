class MonthComponent < CalendarComponent
  #
  #
  def view_template(&block)
    punch_cards(date.beginning_of_month..date.end_of_month)

    div(class: "lg:flex lg:h-full lg:flex-col") do
      show_header(date)
      month_view

      # todays list of events
      div(class: "px-4 py-10 sm:px-6 lg:mx-auto") do
        div(id: "events_list", class: "") do
          # render EventsList.new
        end
      end
    end
  end

  def month_view
    # Month view
    div(class: "shadow ring-1 ring-black ring-opacity-5 lg:flex lg:flex-auto lg:flex-col") do
      month_header
      div(
        class: "flex bg-gray-200 text-xs leading-6 text-gray-700 lg:flex-auto"
      ) do
        small_screen_view
        large_screen_view
      end
    end
  end

  def month_header
    div(class: "grid grid-cols-7 gap-px border-b border-gray-300 bg-gray-200 text-center text-xs font-semibold leading-6 text-gray-700 lg:flex-none") do
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.monday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.monday.second_thirdletter") }
      end
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.tuesday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.tuesday.second_thirdletter") }
      end
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.wednesday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.wednesday.second_thirdletter") }
      end
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.thursday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.thursday.second_thirdletter") }
      end
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.friday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.friday.second_thirdletter") }
      end
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.saturday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.saturday.second_thirdletter") }
      end
      div(class: "flex justify-center bg-white py-2") do
        span { I18n.t("calendar.weekday.sunday.firstletter") }
        span(class: "sr-only sm:not-sr-only") { I18n.t("calendar.weekday.sunday.second_thirdletter") }
      end
    end
  end

  def large_screen_view
    from_date = Date.new(date.year, date.month, 1)
    div(class: "hidden w-full lg:grid lg:grid-cols-7 lg:grid-rows-6 lg:gap-px") do
      dt = Date.new(date.year, date.month, 1).at_beginning_of_week
      #
      # Always include: "relative py-2 px-3"
      # Is current month, include: "bg-white"
      # Is not current month, include: "bg-gray-50 text-gray-500"
      #
      #
      #
      #  1  2  3  4  5  6  7
      #  8  9 10 11 12 13 14
      # 15 16 17 18 19 20 21
      # 22 23 24 25 26 27 28
      # 29 30 31  1  2  3  4
      #  5  6  7  8  9 10 11
      (0..41).each do |day|
        dt += 1.days if day > 0
        large_screen_link(day, dt, from_date)
      end
    end
  end

  def large_screen_link(day, dt, from_date)
    cls = "relative grid grid-cols-2 hover:bg-gray-100 min-h-20 border-t-2"
    cls += holiday?(dt) ? " border-violet-600" : " border-white hover:border-gray-100"
    cls += (dt.month == from_date.month) ? " bg-white" : " bg-gray-50 text-gray-500"
    link_to(
      helpers.new_modal_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", date: I18n.l(dt, format: :short_iso)),
      data: { turbo_stream: true },
      class: "#{cls} bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10",
      role: "menuitem",
      tabindex: "-1") do
      # helpers.calendar_events_url(calendar_id: id, date: dt),
      # data: { turbo_frame: "events_list", turbo_stream: true },
      # class: cls,
      # role: "menuitem",
      # tabindex: "-1") do
      week_number(day, dt, "pl-2 ")
      # all_day_events(dt, "min-h-10")
      # punches?(dt, "pl-1.5")
      events?(dt, :month, { from: dt.beginning_of_month.to_time, to: dt.end_of_month.to_time })

      cls = "absolute col-span-2 place-self-center "
      cls += (dt == Date.today) ? " bg-sky-600 text-white rounded-full w-6 text-center" : "  "
      time(datetime: I18n.l(dt, format: :short_iso), class: "#{cls}") { dt.day }
      span(class: "sr-only") do
        plain "datetime: #{I18n.l(dt, format: :short_iso)} "
        plain "day summary"
      end
    end

    #   div(class: "relative bg-white px-3 py-2") do
    #     time(datetime: "2022-01-07") { "7" }
    #     ol(class: "mt-2") do
    #       li do
    #         a(href: "#", class: "group flex") do
    #           p(
    #             class:
    #               "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
    #           ) { "Date night" }
    #           time(
    #             datetime: "2022-01-08T18:00",
    #             class:
    #               "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
    #           ) { "6PM" }
    #         end
    #       end
    #     end
    #   end
    #   div(class: "relative bg-white px-3 py-2") do
    #     time(
    #       datetime: "2022-01-12",
    #       class:
    #         "flex h-6 w-6 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
    #     ) { "12" }
    #     ol(class: "mt-2") do
    #       li do
    #         a(href: "#", class: "group flex") do
    #           p(
    #             class:
    #               "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
    #           ) { "Sam's birthday party" }
    #           time(
    #             datetime: "2022-01-25T14:00",
    #             class:
    #               "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
    #           ) { "2PM" }
    #         end
    #       end
    #     end
    #   end
  end

  def small_screen_view
    from_date = Date.new(date.year, date.month, 1)
    div(class: "isolate grid w-full grid-cols-7 grid-rows-6 gap-px lg:hidden") do
      #
      # Always include: "flex h-14 flex-col py-2 px-3 hover:bg-gray-100 focus:z-10"
      # Is current month, include: "bg-white"
      # Is not current month, include: "bg-gray-50"
      # Is selected or is today, include: "font-semibold"
      # Is selected, include: "text-white"
      # Is not selected and is today, include: "text-indigo-600"
      # Is not selected and is current month, and is not today, include: "text-gray-900"
      # Is not selected, is not current month, and is not today: "text-gray-500"
      #

      dt = Date.new(date.year, date.month, 1).at_beginning_of_week
      #
      # Always include: "relative py-2 px-3"
      # Is current month, include: "bg-white"
      # Is not current month, include: "bg-gray-50 text-gray-500"
      #
      #
      #
      #  1  2  3  4  5  6  7
      #  8  9 10 11 12 13 14
      # 15 16 17 18 19 20 21
      # 22 23 24 25 26 27 28
      # 29 30 31  1  2  3  4
      #  5  6  7  8  9 10 11
      (0..41).each do |day|
        dt += 1.days if day > 0
        small_screen_link(day, dt, from_date)
      end
    end
  end

  def small_screen_link(day, dt, from_date)
    cls = "relative grid h-14 grid-cols-2 hover:bg-gray-100 focus:z-10 border-t-2"
    cls += (dt.month == from_date.month) ? " bg-white" : " bg-gray-50"
    cls += holiday?(dt) ? " border-violet-600" : " border-white"
    cls += (dt == Date.today && (dt.month == from_date.month)) ? " text-gray-900" : " text-gray-500"
    link_to(
      helpers.new_modal_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", date: I18n.l(dt, format: :short_iso)),
      data: { turbo_stream: true },
      class: cls,
      role: "menuitem",
      tabindex: "-1") do
      week_number(day, dt, "pl-1 h-6 text-[8px]")
      # all_day_events(dt)
      punches?(dt, "pl-0.5")
      events?(dt, :month, { from: dt.beginning_of_month.to_time, to: dt.end_of_month.to_time })

      cls = "absolute col-span-2 place-self-center "
      cls += (dt == Date.today) ? " bg-sky-600 text-white rounded-full w-6 text-center" : "  "
      time(datetime: I18n.l(dt, format: :short_iso), class: "#{cls}") { dt.day }
      span(class: "sr-only") do
        plain "0 events"
      end
    end


    # link_to(
    #   helpers.events_calendar_url(id: id, date: dt),
    #   data: { turbo_frame: "events_list", turbo_stream: true },
    #   # modal view alternative:
    #   # helpers.new_modal_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", date: I18n.l(dt, format: :short_iso)),
    #   # data: { turbo_stream: true },
    #   class: cls,
    #   role: "menuitem",
    #   tabindex: "-1") do
    #   week_number(day, dt, "pl-1 h-6 text-[8px]")
    #   all_day_events(dt)
    #   punches?(dt, "pl-0.5")
    #   events?(dt, "pr-0.5")

    #   cls = "absolute col-span-2 place-self-center "
    #   cls += (dt == Date.today) ? " bg-sky-600 text-white rounded-full w-6 text-center" : "  "
    #   time(datetime: I18n.l(dt, format: :short_iso), class: "#{cls}") { dt.day }
    #   span(class: "sr-only") do
    #     plain "0 events"
    #   end
    # end

    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   comment do
    #     %(Always include: "ml-auto" Is selected, include: "flex h-6 w-6 items-center justify-center rounded-full" Is selected and is today, include: "bg-indigo-600" Is selected and is not today, include: "bg-gray-900")
    #   end
    #   time(datetime: "2021-12-27", class: "ml-auto") { "27" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2021-12-28", class: "ml-auto") { "28" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2021-12-29", class: "ml-auto") { "29" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2021-12-30", class: "ml-auto") { "30" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2021-12-31", class: "ml-auto") { "31" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-01", class: "ml-auto") { "1" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-02", class: "ml-auto") { "2" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-03", class: "ml-auto") { "3" }
    #   span(class: "sr-only") { "2 events" }
    #   span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #   end
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-04", class: "ml-auto") { "4" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-05", class: "ml-auto") { "5" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-06", class: "ml-auto") { "6" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-07", class: "ml-auto") { "7" }
    #   span(class: "sr-only") { "1 event" }
    #   span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #   end
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-08", class: "ml-auto") { "8" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-09", class: "ml-auto") { "9" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-10", class: "ml-auto") { "10" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-11", class: "ml-auto") { "11" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 font-semibold text-indigo-600 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-12", class: "ml-auto") { "12" }
    #   span(class: "sr-only") { "1 event" }
    #   span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #   end
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-13", class: "ml-auto") { "13" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-14", class: "ml-auto") { "14" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-15", class: "ml-auto") { "15" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-16", class: "ml-auto") { "16" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-17", class: "ml-auto") { "17" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-18", class: "ml-auto") { "18" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-19", class: "ml-auto") { "19" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-20", class: "ml-auto") { "20" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-21", class: "ml-auto") { "21" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 font-semibold text-white hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(
    #     datetime: "2022-01-22",
    #     class:
    #       "ml-auto flex h-6 w-6 items-center justify-center rounded-full bg-gray-900"
    #   ) { "22" }
    #   span(class: "sr-only") { "2 events" }
    #   span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #   end
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-23", class: "ml-auto") { "23" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-24", class: "ml-auto") { "24" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-25", class: "ml-auto") { "25" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-26", class: "ml-auto") { "26" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-27", class: "ml-auto") { "27" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-28", class: "ml-auto") { "28" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-29", class: "ml-auto") { "29" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-30", class: "ml-auto") { "30" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-01-31", class: "ml-auto") { "31" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-02-01", class: "ml-auto") { "1" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-02-02", class: "ml-auto") { "2" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-02-03", class: "ml-auto") { "3" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-02-04", class: "ml-auto") { "4" }
    #   span(class: "sr-only") { "1 event" }
    #   span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
    #     span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
    #   end
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-02-05", class: "ml-auto") { "5" }
    #   span(class: "sr-only") { "0 events" }
    # end
    # button(
    #   type: "button",
    #   class:
    #     "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
    # ) do
    #   time(datetime: "2022-02-06", class: "ml-auto") { "6" }
    #   span(class: "sr-only") { "0 events" }
    # end
  end
end
