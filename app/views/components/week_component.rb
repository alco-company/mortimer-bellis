class WeekComponent < CalendarComponent
  def view_template
    div(class: "flex h-full flex-col") do
      show_header(Date.today)

      div(class: "isolate flex flex-auto flex-col overflow-auto bg-white") do
        div(
          style: "width:165%",
          class:
            "flex max-w-full flex-none flex-col sm:max-w-none md:max-w-full"
        ) do
          div(
            class:
              "sticky top-0 z-30 flex-none bg-white shadow ring-1 ring-black ring-opacity-5 sm:pr-8"
          ) do
            div(
              class:
                "grid grid-cols-7 text-sm leading-6 text-gray-500 sm:hidden"
            ) do
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "M "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
                ) { "10" }
              end
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "T "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
                ) { "11" }
              end
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "W "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
                ) { "12" }
              end
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "T "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
                ) { "13" }
              end
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "F "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
                ) { "14" }
              end
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "S "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
                ) { "15" }
              end
              whitespace
              button(
                type: "button",
                class: "flex flex-col items-center pb-3 pt-2"
              ) do
                plain "S "
                span(
                  class:
                    "mt-1 flex h-8 w-8 items-center justify-center font-semibold text-gray-900"
                ) { "16" }
              end
            end
            div(
              class:
                "-mr-px hidden grid-cols-7 divide-x divide-gray-100 border-r border-gray-100 text-sm leading-6 text-gray-500 sm:grid"
            ) do
              div(class: "col-end-1 w-14")
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span do
                  plain "Mon "
                  span(
                    class:
                      "items-center justify-center font-semibold text-gray-900"
                  ) { "10" }
                end
              end
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span do
                  plain "Tue "
                  span(
                    class:
                      "items-center justify-center font-semibold text-gray-900"
                  ) { "11" }
                end
              end
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span(class: "flex items-baseline") do
                  plain "Wed "
                  span(
                    class:
                      "ml-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
                  ) { "12" }
                end
              end
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span do
                  plain "Thu "
                  span(
                    class:
                      "items-center justify-center font-semibold text-gray-900"
                  ) { "13" }
                end
              end
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span do
                  plain "Fri "
                  span(
                    class:
                      "items-center justify-center font-semibold text-gray-900"
                  ) { "14" }
                end
              end
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span do
                  plain "Sat "
                  span(
                    class:
                      "items-center justify-center font-semibold text-gray-900"
                  ) { "15" }
                end
              end
              div(class: "flex items-center justify-center py-3") do
                whitespace
                span do
                  plain "Sun "
                  span(
                    class:
                      "items-center justify-center font-semibold text-gray-900"
                  ) { "16" }
                end
              end
            end
          end
          div(class: "flex flex-auto") do
            div(
              class:
                "sticky left-0 z-10 w-14 flex-none bg-white ring-1 ring-gray-100"
            )
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
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "12AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "1AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "2AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "3AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "4AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "5AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "6AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "7AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "8AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "9AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "10AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "11AM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "12PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "1PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "2PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "3PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "4PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "5PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "6PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "7PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "8PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "9PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "10PM" }
                end
                div
                div do
                  div(
                    class:
                      "sticky left-0 z-20 -ml-14 -mt-2.5 w-14 pr-2 text-right text-xs leading-5 text-gray-400"
                  ) { "11PM" }
                end
                div
              end
              whitespace
              comment { "Vertical lines" }
              div(
                class:
                  "col-start-1 col-end-2 row-start-1 hidden grid-cols-7 grid-rows-1 divide-x divide-gray-100 sm:grid sm:grid-cols-7"
              ) do
                div(class: "col-start-1 row-span-full")
                div(class: "col-start-2 row-span-full")
                div(class: "col-start-3 row-span-full")
                div(class: "col-start-4 row-span-full")
                div(class: "col-start-5 row-span-full")
                div(class: "col-start-6 row-span-full")
                div(class: "col-start-7 row-span-full")
                div(class: "col-start-8 row-span-full w-8")
              end
              whitespace
              comment { "Events" }
              ol(
                class:
                  "col-start-1 col-end-2 row-start-1 grid grid-cols-1 sm:grid-cols-7 sm:pr-8",
                style:
                  "grid-template-rows:1.75 rem repeat(288, minmax(0, 1fr)) auto"
              ) do
                li(
                  class: "relative mt-px flex sm:col-start-3",
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
                      time(datetime: "2022-01-12T06:00") { "6:00 AM" }
                    end
                    whitespace
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
        end
      end
    end
  end
end