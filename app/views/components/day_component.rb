class DayComponent < CalendarComponent

  def view_template(&block)
    div(class: "flex h-full flex-col") do
      show_header(Date.today)

      div(class: "isolate flex flex-auto overflow-hidden bg-white") do
        div(class: "flex flex-auto flex-col overflow-auto") do
          div(
            class:
              "sticky top-0 z-10 grid flex-none grid-cols-7 bg-white text-xs text-gray-500 shadow ring-1 ring-black ring-opacity-5 md:hidden"
          ) do
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "W" }
              whitespace
              comment do
                %(Default: "text-gray-900", Selected: "bg-gray-900 text-white", Today (Not Selected): "text-indigo-600", Today (Selected): "bg-indigo-600 text-white")
              end
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full text-base font-semibold text-gray-900"
              ) { "19" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "T" }
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full text-base font-semibold text-indigo-600"
              ) { "20" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "F" }
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full text-base font-semibold text-gray-900"
              ) { "21" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "S" }
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full bg-gray-900 text-base font-semibold text-white"
              ) { "22" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "S" }
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full text-base font-semibold text-gray-900"
              ) { "23" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "M" }
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full text-base font-semibold text-gray-900"
              ) { "24" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class: "flex flex-col items-center pb-1.5 pt-3"
            ) do
              whitespace
              span { "T" }
              whitespace
              span(
                class:
                  "mt-3 flex h-8 w-8 items-center justify-center rounded-full text-base font-semibold text-gray-900"
              ) { "25" }
              whitespace
            end
          end
          div(class: "flex w-full flex-auto") do
            div(class: "w-14 flex-none bg-white ring-1 ring-gray-100")
            div(class: "grid flex-auto grid-cols-1 grid-rows-1") do
              whitespace
              comment { "Horizontal lines" }
              div(
                class:
                  "col-start-1 col-end-2 row-start-1 grid divide-y divide-gray-100",
                style: "grid-template-rows:repeat(48, minmax(3.5rem, 1fr))"
              ) do
                div(class: "row-end-1 h-7")
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "12AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "1AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "2AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "3AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "4AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "5AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "6AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "7AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "8AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "9AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "10AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "11AM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "12PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "1PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "2PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "3PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "4PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "5PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "6PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "7PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "8PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "9PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "10PM" }
                end
                div
                div do
                  div(
                    class:
                      "-ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "11PM" }
                end
                div
              end
              whitespace
              comment { "Events" }
              ol(
                class: "col-start-1 col-end-2 row-start-1 grid grid-cols-1",
                style:
                  "grid-template-rows:1.75 rem repeat(288, minmax(0, 1fr)) auto"
              ) do
                li(
                  class: "relative mt-px flex",
                  style: "grid-row:74 /span 12"
                ) do
                  whitespace
                  a(
                    href: "#",
                    class:
                      "group absolute inset-1 flex flex-col overflow-y-auto rounded-lg bg-blue-50 p-2 text-xs leading-5 hover:bg-blue-100"
                  ) do
                    p(class: "order-1 font-semibold text-blue-700") do
                      "Breakfast"
                    end
                    p(class: "text-blue-500 group-hover:text-blue-700") do
                      time(datetime: "2022-01-22T06:00") { "6:00 AM" }
                    end
                    whitespace
                  end
                end
                li(
                  class: "relative mt-px flex",
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
                    p(
                      class: "order-1 text-pink-500 group-hover:text-pink-700"
                    ) { "John F. Kennedy International Airport" }
                    p(class: "text-pink-500 group-hover:text-pink-700") do
                      time(datetime: "2022-01-22T07:30") { "7:30 AM" }
                    end
                    whitespace
                  end
                end
                li(
                  class: "relative mt-px flex",
                  style: "grid-row:134 /span 18"
                ) do
                  whitespace
                  a(
                    href: "#",
                    class:
                      "group absolute inset-1 flex flex-col overflow-y-auto rounded-lg bg-indigo-50 p-2 text-xs leading-5 hover:bg-indigo-100"
                  ) do
                    p(class: "order-1 font-semibold text-indigo-700") do
                      "Sightseeing"
                    end
                    p(
                      class:
                        "order-1 text-indigo-500 group-hover:text-indigo-700"
                    ) { "Eiffel Tower" }
                    p(class: "text-indigo-500 group-hover:text-indigo-700") do
                      time(datetime: "2022-01-22T11:00") { "11:00 AM" }
                    end
                    whitespace
                  end
                end
              end
            end
          end
        end
        div(
          class:
            "hidden w-1/2 max-w-md flex-none border-l border-gray-100 px-8 py-10 md:block"
        ) do
          div(class: "flex items-center text-center text-gray-900") do
            whitespace
            button(
              type: "button",
              class:
                "-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500"
            ) do
              whitespace
              span(class: "sr-only") { "Previous month" }
              whitespace
              svg(
                class: "h-5 w-5",
                viewbox: "0 0 20 20",
                fill: "currentColor",
                aria_hidden: "true"
              ) do |s|
                s.path(
                  fill_rule: "evenodd",
                  d:
                    "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z",
                  clip_rule: "evenodd"
                )
              end
              whitespace
            end
            div(class: "flex-auto text-sm font-semibold") { "January 2022" }
            whitespace
            button(
              type: "button",
              class:
                "-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500"
            ) do
              whitespace
              span(class: "sr-only") { "Next month" }
              whitespace
              svg(
                class: "h-5 w-5",
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
              whitespace
            end
          end
          div(
            class:
              "mt-6 grid grid-cols-7 text-center text-xs leading-6 text-gray-500"
          ) do
            div { "M" }
            div { "T" }
            div { "W" }
            div { "T" }
            div { "F" }
            div { "S" }
            div { "S" }
          end
          div(
            class:
              "isolate mt-2 grid grid-cols-7 gap-px rounded-lg bg-gray-200 text-sm shadow ring-1 ring-gray-200"
          ) do
            whitespace
            comment do
              %(Always include: "py-1.5 hover:bg-gray-100 focus:z-10" Is current month, include: "bg-white" Is not current month, include: "bg-gray-50" Is selected or is today, include: "font-semibold" Is selected, include: "text-white" Is not selected, is not today, and is current month, include: "text-gray-900" Is not selected, is not today, and is not current month, include: "text-gray-400" Is today and is not selected, include: "text-indigo-600" Top left day, include: "rounded-tl-lg" Top right day, include: "rounded-tr-lg" Bottom left day, include: "rounded-bl-lg" Bottom right day, include: "rounded-br-lg")
            end
            whitespace
            button(
              type: "button",
              class:
                "rounded-tl-lg bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              comment do
                %(Always include: "mx-auto flex h-7 w-7 items-center justify-center rounded-full" Is selected and is today, include: "bg-indigo-600" Is selected and is not today, include: "bg-gray-900")
              end
              whitespace
              time(
                datetime: "2021-12-27",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "27" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2021-12-28",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "28" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2021-12-29",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "29" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2021-12-30",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "30" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2021-12-31",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "31" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-01",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "1" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "rounded-tr-lg bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-02",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "2" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-03",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "3" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-04",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "4" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-05",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "5" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-06",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "6" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-07",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "7" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-08",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "8" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-09",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "9" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-10",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "10" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-11",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "11" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-12",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "12" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-13",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "13" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-14",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "14" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-15",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "15" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-16",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "16" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-17",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "17" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-18",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "18" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-19",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "19" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 font-semibold text-indigo-600 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-20",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "20" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-21",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "21" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-22",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full bg-gray-900 font-semibold text-white"
              ) { "22" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-23",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "23" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-24",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "24" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-25",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "25" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-26",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "26" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-27",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "27" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-28",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "28" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-29",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "29" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-30",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "30" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "rounded-bl-lg bg-white py-1.5 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-01-31",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "31" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-02-01",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "1" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-02-02",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "2" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-02-03",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "3" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-02-04",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "4" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-02-05",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "5" }
              whitespace
            end
            whitespace
            button(
              type: "button",
              class:
                "rounded-br-lg bg-gray-50 py-1.5 text-gray-400 hover:bg-gray-100 focus:z-10"
            ) do
              whitespace
              time(
                datetime: "2022-02-06",
                class:
                  "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
              ) { "6" }
              whitespace
            end
          end
        end
      end
    end
  end
end

      # header(
      #   class:
      #     "flex flex-none items-center justify-between border-b border-gray-200 px-6 py-4"
      # ) do
      #   div do
      #     h1(class: "text-base font-semibold leading-6 text-gray-900") do
      #       whitespace
      #       time(datetime: "2022-01-22", class: "sm:hidden") { "Jan 22, 2022" }
      #       whitespace
      #       time(datetime: "2022-01-22", class: "hidden sm:inline") do
      #         "January 22, 2022"
      #       end
      #     end
      #     p(class: "mt-1 text-sm text-gray-500") { "Saturday" }
      #   end
      #   div(class: "flex items-center") do
      #     div(
      #       class:
      #         "relative flex items-center rounded-md bg-white shadow-sm md:items-stretch"
      #     ) do
      #       whitespace
      #       button(
      #         type: "button",
      #         class:
      #           "flex h-9 w-12 items-center justify-center rounded-l-md border-y border-l border-gray-300 pr-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pr-0 md:hover:bg-gray-50"
      #       ) do
      #         whitespace
      #         span(class: "sr-only") { "Previous day" }
      #         whitespace
      #         svg(
      #           class: "h-5 w-5",
      #           viewbox: "0 0 20 20",
      #           fill: "currentColor",
      #           aria_hidden: "true"
      #         ) do |s|
      #           s.path(
      #             fill_rule: "evenodd",
      #             d:
      #               "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z",
      #             clip_rule: "evenodd"
      #           )
      #         end
      #         whitespace
      #       end
      #       whitespace
      #       button(
      #         type: "button",
      #         class:
      #           "hidden border-y border-gray-300 px-3.5 text-sm font-semibold text-gray-900 hover:bg-gray-50 focus:relative md:block"
      #       ) { "Today" }
      #       whitespace
      #       span(class: "relative -mx-px h-5 w-px bg-gray-300 md:hidden")
      #       whitespace
      #       button(
      #         type: "button",
      #         class:
      #           "flex h-9 w-12 items-center justify-center rounded-r-md border-y border-r border-gray-300 pl-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pl-0 md:hover:bg-gray-50"
      #       ) do
      #         whitespace
      #         span(class: "sr-only") { "Next day" }
      #         whitespace
      #         svg(
      #           class: "h-5 w-5",
      #           viewbox: "0 0 20 20",
      #           fill: "currentColor",
      #           aria_hidden: "true"
      #         ) do |s|
      #           s.path(
      #             fill_rule: "evenodd",
      #             d:
      #               "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z",
      #             clip_rule: "evenodd"
      #           )
      #         end
      #         whitespace
      #       end
      #     end
      #     div(class: "hidden md:ml-4 md:flex md:items-center") do
      #       div(class: "relative") do
      #         whitespace
      #         button(
      #           type: "button",
      #           class:
      #             "flex items-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50",
      #           id: "menu-button",
      #           aria_expanded: "false",
      #           aria_haspopup: "true"
      #         ) do
      #           plain " Day view "
      #           svg(
      #             class: "-mr-1 h-5 w-5 text-gray-400",
      #             viewbox: "0 0 20 20",
      #             fill: "currentColor",
      #             aria_hidden: "true"
      #           ) do |s|
      #             s.path(
      #               fill_rule: "evenodd",
      #               d:
      #                 "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z",
      #               clip_rule: "evenodd"
      #             )
      #           end
      #           whitespace
      #         end
      #         whitespace
      #         comment do
      #           %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      #         end
      #         div(
      #           class:
      #             "absolute right-0 z-10 mt-3 w-36 origin-top-right overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
      #           role: "menu",
      #           aria_orientation: "vertical",
      #           aria_labelledby: "menu-button",
      #           tabindex: "-1"
      #         ) do
      #           div(class: "py-1", role: "none") do
      #             whitespace
      #             comment do
      #               %(Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700")
      #             end
      #             whitespace
      #             a(
      #               href: "#",
      #               class: "block px-4 py-2 text-sm text-gray-700",
      #               role: "menuitem",
      #               tabindex: "-1",
      #               id: "menu-item-0"
      #             ) { "Day view" }
      #             whitespace
      #             a(
      #               href: "#",
      #               class: "block px-4 py-2 text-sm text-gray-700",
      #               role: "menuitem",
      #               tabindex: "-1",
      #               id: "menu-item-1"
      #             ) { "Week view" }
      #             whitespace
      #             a(
      #               href: "#",
      #               class: "block px-4 py-2 text-sm text-gray-700",
      #               role: "menuitem",
      #               tabindex: "-1",
      #               id: "menu-item-2"
      #             ) { "Month view" }
      #             whitespace
      #             a(
      #               href: "#",
      #               class: "block px-4 py-2 text-sm text-gray-700",
      #               role: "menuitem",
      #               tabindex: "-1",
      #               id: "menu-item-3"
      #             ) { "Year view" }
      #           end
      #         end
      #       end
      #       div(class: "ml-6 h-6 w-px bg-gray-300")
      #       whitespace
      #       button(
      #         type: "button",
      #         class:
      #           "ml-6 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500"
      #       ) { "Add event" }
      #     end
      #     div(class: "relative ml-6 md:hidden") do
      #       whitespace
      #       button(
      #         type: "button",
      #         class:
      #           "-mx-2 flex items-center rounded-full border border-transparent p-2 text-gray-400 hover:text-gray-500",
      #         id: "menu-0-button",
      #         aria_expanded: "false",
      #         aria_haspopup: "true"
      #       ) do
      #         whitespace
      #         span(class: "sr-only") { "Open menu" }
      #         whitespace
      #         svg(
      #           class: "h-5 w-5",
      #           viewbox: "0 0 20 20",
      #           fill: "currentColor",
      #           aria_hidden: "true"
      #         ) do |s|
      #           s.path(
      #             d:
      #               "M3 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM8.5 10a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM15.5 8.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3z"
      #           )
      #         end
      #         whitespace
      #       end
      #       whitespace
      #       comment do
      #         %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      #       end
      #       div(
      #         class:
      #           "absolute right-0 z-10 mt-3 w-36 origin-top-right divide-y divide-gray-100 overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
      #         role: "menu",
      #         aria_orientation: "vertical",
      #         aria_labelledby: "menu-0-button",
      #         tabindex: "-1"
      #       ) do
      #         div(class: "py-1", role: "none") do
      #           whitespace
      #           comment do
      #             %(Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700")
      #           end
      #           whitespace
      #           a(
      #             href: "#",
      #             class: "block px-4 py-2 text-sm text-gray-700",
      #             role: "menuitem",
      #             tabindex: "-1",
      #             id: "menu-0-item-0"
      #           ) { "Create event" }
      #         end
      #         div(class: "py-1", role: "none") do
      #           whitespace
      #           a(
      #             href: "#",
      #             class: "block px-4 py-2 text-sm text-gray-700",
      #             role: "menuitem",
      #             tabindex: "-1",
      #             id: "menu-0-item-1"
      #           ) { "Go to today" }
      #         end
      #         div(class: "py-1", role: "none") do
      #           whitespace
      #           a(
      #             href: "#",
      #             class: "block px-4 py-2 text-sm text-gray-700",
      #             role: "menuitem",
      #             tabindex: "-1",
      #             id: "menu-0-item-2"
      #           ) { "Day view" }
      #           whitespace
      #           a(
      #             href: "#",
      #             class: "block px-4 py-2 text-sm text-gray-700",
      #             role: "menuitem",
      #             tabindex: "-1",
      #             id: "menu-0-item-3"
      #           ) { "Week view" }
      #           whitespace
      #           a(
      #             href: "#",
      #             class: "block px-4 py-2 text-sm text-gray-700",
      #             role: "menuitem",
      #             tabindex: "-1",
      #             id: "menu-0-item-4"
      #           ) { "Month view" }
      #           whitespace
      #           a(
      #             href: "#",
      #             class: "block px-4 py-2 text-sm text-gray-700",
      #             role: "menuitem",
      #             tabindex: "-1",
      #             id: "menu-0-item-5"
      #           ) { "Year view" }
      #         end
      #       end
      #     end
      #   end
      #   whitespace
      # end
