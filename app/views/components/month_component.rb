class MonthComponent < CalendarComponent
  #
  #
  def view_template(&block)
    div(class: "lg:flex lg:h-full lg:flex-col") do
      show_header(Date.today)

      # Month view
      div(
        class:
          "shadow ring-1 ring-black ring-opacity-5 lg:flex lg:flex-auto lg:flex-col"
      ) do
        div(
          class:
            "grid grid-cols-7 gap-px border-b border-gray-300 bg-gray-200 text-center text-xs font-semibold leading-6 text-gray-700 lg:flex-none"
        ) do
          div(class: "flex justify-center bg-white py-2") do
            span { "M" }
            span(class: "sr-only sm:not-sr-only") { "on" }
          end
          div(class: "flex justify-center bg-white py-2") do
            span { "T" }
            span(class: "sr-only sm:not-sr-only") { "ue" }
          end
          div(class: "flex justify-center bg-white py-2") do
            span { "W" }
            span(class: "sr-only sm:not-sr-only") { "ed" }
          end
          div(class: "flex justify-center bg-white py-2") do
            span { "T" }
            span(class: "sr-only sm:not-sr-only") { "hu" }
          end
          div(class: "flex justify-center bg-white py-2") do
            span { "F" }
            span(class: "sr-only sm:not-sr-only") { "ri" }
          end
          div(class: "flex justify-center bg-white py-2") do
            span { "S" }
            span(class: "sr-only sm:not-sr-only") { "at" }
          end
          div(class: "flex justify-center bg-white py-2") do
            span { "S" }
            span(class: "sr-only sm:not-sr-only") { "un" }
          end
        end
        div(
          class: "flex bg-gray-200 text-xs leading-6 text-gray-700 lg:flex-auto"
        ) do
          div(
            class:
              "hidden w-full lg:grid lg:grid-cols-7 lg:grid-rows-6 lg:gap-px"
          ) do
            comment do
              %(Always include: "relative py-2 px-3" Is current month, include: "bg-white" Is not current month, include: "bg-gray-50 text-gray-500")
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              comment do
                %(Is today, include: "flex h-6 w-6 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white")
              end
              time(datetime: "2021-12-27") { "27" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2021-12-28") { "28" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2021-12-29") { "29" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2021-12-30") { "30" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2021-12-31") { "31" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-01") { "1" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-01") { "2" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-03") { "3" }
              ol(class: "mt-2") do
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Design review" }
                    time(
                      datetime: "2022-01-03T10:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "10AM" }
                  end
                end
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Sales meeting" }
                    time(
                      datetime: "2022-01-03T14:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "2PM" }
                  end
                end
              end
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-04") { "4" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-05") { "5" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-06") { "6" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-07") { "7" }
              ol(class: "mt-2") do
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Date night" }
                    time(
                      datetime: "2022-01-08T18:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "6PM" }
                  end
                end
              end
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-08") { "8" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-09") { "9" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-10") { "10" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-11") { "11" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(
                datetime: "2022-01-12",
                class:
                  "flex h-6 w-6 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
              ) { "12" }
              ol(class: "mt-2") do
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Sam's birthday party" }
                    time(
                      datetime: "2022-01-25T14:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "2PM" }
                  end
                end
              end
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-13") { "13" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-14") { "14" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-15") { "15" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-16") { "16" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-17") { "17" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-18") { "18" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-19") { "19" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-20") { "20" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-21") { "21" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-22") { "22" }
              ol(class: "mt-2") do
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Maple syrup museum" }
                    time(
                      datetime: "2022-01-22T15:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "3PM" }
                  end
                end
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Hockey game" }
                    time(
                      datetime: "2022-01-22T19:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "7PM" }
                  end
                end
              end
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-23") { "23" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-24") { "24" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-25") { "25" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-26") { "26" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-27") { "27" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-28") { "28" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-29") { "29" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-30") { "30" }
            end
            div(class: "relative bg-white px-3 py-2") do
              time(datetime: "2022-01-31") { "31" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2022-02-01") { "1" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2022-02-02") { "2" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2022-02-03") { "3" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2022-02-04") { "4" }
              ol(class: "mt-2") do
                li do
                  a(href: "#", class: "group flex") do
                    p(
                      class:
                        "flex-auto truncate font-medium text-gray-900 group-hover:text-indigo-600"
                    ) { "Cinema with friends" }
                    time(
                      datetime: "2022-02-04T21:00",
                      class:
                        "ml-3 hidden flex-none text-gray-500 group-hover:text-indigo-600 xl:block"
                    ) { "9PM" }
                  end
                end
              end
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2022-02-05") { "5" }
            end
            div(class: "relative bg-gray-50 px-3 py-2 text-gray-500") do
              time(datetime: "2022-02-06") { "6" }
            end
          end
          div(
            class:
              "isolate grid w-full grid-cols-7 grid-rows-6 gap-px lg:hidden"
          ) do
            comment do
              %(Always include: "flex h-14 flex-col py-2 px-3 hover:bg-gray-100 focus:z-10" Is current month, include: "bg-white" Is not current month, include: "bg-gray-50" Is selected or is today, include: "font-semibold" Is selected, include: "text-white" Is not selected and is today, include: "text-indigo-600" Is not selected and is current month, and is not today, include: "text-gray-900" Is not selected, is not current month, and is not today: "text-gray-500")
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              comment do
                %(Always include: "ml-auto" Is selected, include: "flex h-6 w-6 items-center justify-center rounded-full" Is selected and is today, include: "bg-indigo-600" Is selected and is not today, include: "bg-gray-900")
              end
              time(datetime: "2021-12-27", class: "ml-auto") { "27" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2021-12-28", class: "ml-auto") { "28" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2021-12-29", class: "ml-auto") { "29" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2021-12-30", class: "ml-auto") { "30" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2021-12-31", class: "ml-auto") { "31" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-01", class: "ml-auto") { "1" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-02", class: "ml-auto") { "2" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-03", class: "ml-auto") { "3" }
              span(class: "sr-only") { "2 events" }
              span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
              end
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-04", class: "ml-auto") { "4" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-05", class: "ml-auto") { "5" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-06", class: "ml-auto") { "6" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-07", class: "ml-auto") { "7" }
              span(class: "sr-only") { "1 event" }
              span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
              end
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-08", class: "ml-auto") { "8" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-09", class: "ml-auto") { "9" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-10", class: "ml-auto") { "10" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-11", class: "ml-auto") { "11" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 font-semibold text-indigo-600 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-12", class: "ml-auto") { "12" }
              span(class: "sr-only") { "1 event" }
              span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
              end
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-13", class: "ml-auto") { "13" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-14", class: "ml-auto") { "14" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-15", class: "ml-auto") { "15" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-16", class: "ml-auto") { "16" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-17", class: "ml-auto") { "17" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-18", class: "ml-auto") { "18" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-19", class: "ml-auto") { "19" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-20", class: "ml-auto") { "20" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-21", class: "ml-auto") { "21" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 font-semibold text-white hover:bg-gray-100 focus:z-10"
            ) do
              time(
                datetime: "2022-01-22",
                class:
                  "ml-auto flex h-6 w-6 items-center justify-center rounded-full bg-gray-900"
              ) { "22" }
              span(class: "sr-only") { "2 events" }
              span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
              end
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-23", class: "ml-auto") { "23" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-24", class: "ml-auto") { "24" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-25", class: "ml-auto") { "25" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-26", class: "ml-auto") { "26" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-27", class: "ml-auto") { "27" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-28", class: "ml-auto") { "28" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-29", class: "ml-auto") { "29" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-30", class: "ml-auto") { "30" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-white px-3 py-2 text-gray-900 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-01-31", class: "ml-auto") { "31" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-02-01", class: "ml-auto") { "1" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-02-02", class: "ml-auto") { "2" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-02-03", class: "ml-auto") { "3" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-02-04", class: "ml-auto") { "4" }
              span(class: "sr-only") { "1 event" }
              span(class: "-mx-0.5 mt-auto flex flex-wrap-reverse") do
                span(class: "mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-gray-400")
              end
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-02-05", class: "ml-auto") { "5" }
              span(class: "sr-only") { "0 events" }
            end
            button(
              type: "button",
              class:
                "flex h-14 flex-col bg-gray-50 px-3 py-2 text-gray-500 hover:bg-gray-100 focus:z-10"
            ) do
              time(datetime: "2022-02-06", class: "ml-auto") { "6" }
              span(class: "sr-only") { "0 events" }
            end
          end
        end
      end

      # todays list of events
      div(class: "px-4 py-10 sm:px-6 lg:hidden") do
        div(class: "") do
          render EventsList.new
        end
      end
      #   ol(class: "divide-y divide-gray-100 overflow-hidden rounded-lg bg-white text-sm shadow ring-1 ring-black ring-opacity-5") do
      #     # mobile_listed_events.each do |event|
      #     [ "Maple syrup museum", "Hockey Game" ].each do |event|
      #       listed_event(event)
      #     end
      #   end
      # end
    end
  end

  def listed_event(event)
    li(
      class:
        "group flex p-4 pr-6 focus-within:bg-gray-50 hover:bg-gray-50"
    ) do
      div(class: "flex-auto") do
        p(class: "font-semibold text-gray-900") { event }
        time(
          datetime: "2022-01-15T09:00",
          class: "mt-2 flex items-center text-gray-700"
        ) do
          svg(
            class: "mr-2 h-5 w-5 text-gray-400",
            viewbox: "0 0 20 20",
            fill: "currentColor",
            aria_hidden: "true"
          ) do |s|
            s.path(
              fill_rule: "evenodd",
              d:
                "M10 18a8 8 0 100-16 8 8 0 000 16zm.75-13a.75.75 0 00-1.5 0v5c0 .414.336.75.75.75h4a.75.75 0 000-1.5h-3.25V5z",
              clip_rule: "evenodd"
            )
          end
          plain " 3PM "
        end
      end
      a(
        href: "#",
        class:
          "ml-6 flex-none self-center rounded-md bg-white px-3 py-2 font-semibold text-gray-900 opacity-0 shadow-sm ring-1 ring-inset ring-gray-300 hover:ring-gray-400 focus:opacity-100 group-hover:opacity-100"
      ) do
        plain "Edit"
        span(class: "sr-only") { ", #{event}" }
      end
    end
  end
end
