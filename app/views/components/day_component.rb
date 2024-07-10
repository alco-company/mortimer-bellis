class DayComponent < CalendarComponent

  def view_template(&block)
    div(class: "flex h-full flex-col") do
      show_header(date)

      div(class: "isolate flex flex-auto overflow-hidden bg-white") do
        div(class: "flex flex-auto flex-col overflow-auto") do
          show_weekday_headers("md:hidden")

          div(class: "flex w-full flex-auto") do
            div(class: "w-14 flex-none bg-white ring-1 ring-gray-100")
            div(class: "grid flex-auto grid-cols-1 grid-rows-1") do
              whitespace
              comment { "Horizontal lines" }
              show_horizontal_lines
              show_events(" grid-cols-1")
            end
          end
        end

        # month calendar
        div(
          class:
            "hidden w-1/2 max-w-md flex-none border-l border-gray-100 px-8 py-10 md:block"
        ) do
          month_component(date.month, true)
          # div(class: "flex items-center text-center text-gray-900") do
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500"
          #   ) do
          #     whitespace
          #     span(class: "sr-only") { "Previous month" }
          #     whitespace
          #     svg(
          #       class: "h-5 w-5",
          #       viewbox: "0 0 20 20",
          #       fill: "currentColor",
          #       aria_hidden: "true"
          #     ) do |s|
          #       s.path(
          #         fill_rule: "evenodd",
          #         d:
          #           "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z",
          #         clip_rule: "evenodd"
          #       )
          #     end
          #     whitespace
          #   end
          #   div(class: "flex-auto text-sm font-semibold") { "January 2022" }
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500"
          #   ) do
          #     whitespace
          #     span(class: "sr-only") { "Next month" }
          #     whitespace
          #     svg(
          #       class: "h-5 w-5",
          #       viewbox: "0 0 20 20",
          #       fill: "currentColor",
          #       aria_hidden: "true"
          #     ) do |s|
          #       s.path(
          #         fill_rule: "evenodd",
          #         d:
          #           "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z",
          #         clip_rule: "evenodd"
          #       )
          #     end
          #     whitespace
          #   end
          # end
          # div(
          #   class:
          #     "mt-6 grid grid-cols-7 text-center text-xs leading-6 text-gray-500"
          # ) do
          #   div { "M" }
          #   div { "T" }
          #   div { "W" }
          #   div { "T" }
          #   div { "F" }
          #   div { "S" }
          #   div { "S" }
          # end
          # div(
          #   class:
          #     "isolate mt-2 grid grid-cols-7 gap-px rounded-lg bg-gray-200 text-sm shadow ring-1 ring-gray-200"
          # ) do
          #   whitespace
          #   comment do
          #     %(Always include: "py-1.5 hover:bg-gray-100 focus:z-10" Is current month, include: "bg-white" Is not current month, include: "bg-gray-50" Is selected or is today, include: "font-semibold" Is selected, include: "text-white" Is not selected, is not today, and is current month, include: "text-gray-900" Is not selected, is not today, and is not current month, include: "text-gray-400" Is today and is not selected, include: "text-indigo-600" Top left day, include: "rounded-tl-lg" Top right day, include: "rounded-tr-lg" Bottom left day, include: "rounded-bl-lg" Bottom right day, include: "rounded-br-lg")
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "rounded-tl-lg bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     comment do
          #       %(Always include: "mx-auto flex h-7 w-7 items-center justify-center rounded-full" Is selected and is today, include: "bg-indigo-600" Is selected and is not today, include: "bg-gray-900")
          #     end
          #     whitespace
          #     time(
          #       datetime: "2021-12-27",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "27" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2021-12-28",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "28" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2021-12-29",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "29" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2021-12-30",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "30" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2021-12-31",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "31" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-01",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "1" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "rounded-tr-lg bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-02",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "2" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-03",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "3" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-04",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "4" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-05",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "5" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-06",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "6" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-07",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "7" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-08",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "8" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-09",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "9" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-10",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "10" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-11",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "11" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-12",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "12" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-13",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "13" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-14",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "14" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-15",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "15" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-16",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "16" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-17",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "17" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-18",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "18" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-19",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "19" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 font-semibold text-indigo-600 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-20",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "20" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-21",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "21" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-22",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full bg-gray-900 font-semibold text-white"
          #     ) { "22" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-23",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "23" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-24",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "24" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-25",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "25" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-26",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "26" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-27",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "27" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-28",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "28" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-29",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "29" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-30",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "30" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "rounded-bl-lg bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-01-31",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "31" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-02-01",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "1" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-02-02",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "2" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-02-03",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "3" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-02-04",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "4" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-02-05",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "5" }
          #     whitespace
          #   end
          #   whitespace
          #   button(
          #     type: "button",
          #     class:
          #       "rounded-br-lg bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
          #   ) do
          #     whitespace
          #     time(
          #       datetime: "2022-02-06",
          #       class:
          #         "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
          #     ) { "6" }
          #     whitespace
          #   end
          # end
        end
      end
    end
  end
end
