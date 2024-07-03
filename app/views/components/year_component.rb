class YearComponent < CalendarComponent

  def view_template
    div do
      show_header(date)

      div(class: "bg-white") do
        div(
          class:
            "mx-auto grid max-w-3xl grid-cols-1 gap-x-8 gap-y-16 px-4 py-16 sm:grid-cols-2 sm:px-6 xl:max-w-none xl:grid-cols-3 xl:px-8 2xl:grid-cols-4"
        ) do
          whitespace
          (1..12).each do |month|
            month_component(month)
          end
        end
      end
    end
  end

  def month_component(month)
    from_date = Date.new(date.year, month, 1)
    section(class: "text-center") do
      h2(class: "text-sm font-semibold text-gray-900") { I18n.l(from_date, format: :month_name) }
      dt = Date.new(date.year, month, 1).at_beginning_of_week
      div(
        class: "mt-6 grid grid-cols-7 text-xs leading-6 text-gray-500"
      ) do
        div { "M" }
        div { "T" }
        div { "W" }
        div { "T" }
        div { "F" }
        div { "S" }
        div { "S" }
      end
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
          # button(type: "button",
          #   data: { action: "click->calendar#showDaySummary", date: I18n.l(dt, format: :short_iso) },
          #   class: "#{cls} bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10") do
          #   # Always include: "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #   # Is today, include: "bg-indigo-600 font-semibold text-white")
          #   cls = (dt == Date.today && (dt.month == from_date.month)) ? "bg-sky-600 font-semibold text-white" : ""
          #   time(datetime: I18n.l(dt, format: :short_iso), class: "#{cls} mx-auto flex h-7 w-7 items-center justify-center rounded-full") { dt.day }
          # end
          link_to(
            helpers.modal_new_url(id: id, modal_form: "day_summary", resource_class: "calendar", modal_next_step: "accept", date: I18n.l(dt, format: :short_iso)),
            data: { turbo_stream: true },
            # link_to helpers.delete_all_url(),
            # data: { turbo_method: :delete, turbo_confirm: "Are you sure?", turbo_stream: true, action: "click->contextmenu#hide" },
            class: "#{cls} bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10",
            role: "menuitem",
            tabindex: "-1") do
            cls = (dt == Date.today && (dt.month == from_date.month)) ? "bg-sky-600 font-semibold text-white" : ""
            time(datetime: I18n.l(dt, format: :short_iso), class: "#{cls} mx-auto flex h-7 w-7 items-center justify-center rounded-full") { dt.day }
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
