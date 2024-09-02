class ActivityList < Phlex::HTML
  def view_template
    comment { "Activity section" }
    h2(
      class:
        "mx-auto mt-8 max-w-6xl px-4 text-lg font-medium leading-6 text-gray-900 sm:px-6 lg:px-8"
    ) { "Recent activity" }

    comment { "Activity list (smallest breakpoint only)" }
    div(class: "shadow sm:hidden") do
      ul(
        role: "list",
        class: "mt-2 divide-y divide-gray-200 overflow-hidden shadow sm:hidden"
      ) do
        li do
          a(href: "#", class: "block bg-white px-4 py-4 hover:bg-gray-50") do
            span(class: "flex items-center space-x-4") do
              span(class: "flex flex-1 space-x-2 truncate") do
                svg(
                  class: "h-5 w-5 flex-shrink-0 text-gray-400",
                  viewbox: "0 0 20 20",
                  fill: "currentColor",
                  aria_hidden: "true"
                ) do |s|
                  s.path(
                    fill_rule: "evenodd",
                    d:
                      "M1 4a1 1 0 011-1h16a1 1 0 011 1v8a1 1 0 01-1 1H2a1 1 0 01-1-1V4zm12 4a3 3 0 11-6 0 3 3 0 016 0zM4 9a1 1 0 100-2 1 1 0 000 2zm13-1a1 1 0 11-2 0 1 1 0 012 0zM1.75 14.5a.75.75 0 000 1.5c4.417 0 8.693.603 12.749 1.73 1.111.309 2.251-.512 2.251-1.696v-.784a.75.75 0 00-1.5 0v.784a.272.272 0 01-.35.25A49.043 49.043 0 001.75 14.5z",
                    clip_rule: "evenodd"
                  )
                end
                span(class: "flex flex-col truncate text-sm text-gray-500") do
                  span(class: "truncate") { "Payment to Molly Sanders" }
                  span do
                    span(class: "font-medium text-gray-900") { "$20,000" }
                    plain " USD"
                  end
                  time(datetime: "2020-07-11") { "July 11, 2020" }
                end
              end
              svg(
                class: "h-5 w-5 flex-shrink-0 text-gray-400",
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
            end
          end
        end
        comment { "More transactions..." }
      end
      nav(
        class:
          "flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3",
        aria_label: "Pagination"
      ) do
        div(class: "flex flex-1 justify-between") do
          a(
            href: "#",
            class:
              "relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          ) { "Previous" }
          a(
            href: "#",
            class:
              "relative ml-3 inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          ) { "Next" }
        end
      end
    end

    comment { "Activity table (small breakpoint and up)" }
    div(class: "hidden sm:block") do
      div(class: "mx-auto max-w-6xl px-4 sm:px-6 lg:px-8") do
        div(class: "mt-2 flex flex-col") do
          div(
            class:
              "min-w-full overflow-hidden overflow-x-auto align-middle shadow sm:rounded-lg"
          ) do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead do
                tr do
                  th(
                    class:
                      "bg-gray-50 px-6 py-3 text-left text-sm font-semibold text-gray-900",
                    scope: "col"
                  ) { "Transaction" }
                  th(
                    class:
                      "bg-gray-50 px-6 py-3 text-right text-sm font-semibold text-gray-900",
                    scope: "col"
                  ) { "Amount" }
                  th(
                    class:
                      "hidden bg-gray-50 px-6 py-3 text-left text-sm font-semibold text-gray-900 md:block",
                    scope: "col"
                  ) { "Status" }
                  th(
                    class:
                      "bg-gray-50 px-6 py-3 text-right text-sm font-semibold text-gray-900",
                    scope: "col"
                  ) { "Date" }
                end
              end
              tbody(class: "divide-y divide-gray-200 bg-white") do
                tr(class: "bg-white") do
                  td(
                    class:
                      "w-full max-w-0 whitespace-nowrap px-6 py-4 text-sm text-gray-900"
                  ) do
                    div(class: "flex") do
                      a(
                        href: "#",
                        class: "group inline-flex space-x-2 truncate text-sm"
                      ) do
                        svg(
                          class:
                            "h-5 w-5 flex-shrink-0 text-gray-400 group-hover:text-gray-500",
                          viewbox: "0 0 20 20",
                          fill: "currentColor",
                          aria_hidden: "true"
                        ) do |s|
                          s.path(
                            fill_rule: "evenodd",
                            d:
                              "M1 4a1 1 0 011-1h16a1 1 0 011 1v8a1 1 0 01-1 1H2a1 1 0 01-1-1V4zm12 4a3 3 0 11-6 0 3 3 0 016 0zM4 9a1 1 0 100-2 1 1 0 000 2zm13-1a1 1 0 11-2 0 1 1 0 012 0zM1.75 14.5a.75.75 0 000 1.5c4.417 0 8.693.603 12.749 1.73 1.111.309 2.251-.512 2.251-1.696v-.784a.75.75 0 00-1.5 0v.784a.272.272 0 01-.35.25A49.043 49.043 0 001.75 14.5z",
                            clip_rule: "evenodd"
                          )
                        end
                        p(
                          class:
                            "truncate text-gray-500 group-hover:text-gray-900"
                        ) { "Payment to Molly Sanders" }
                      end
                    end
                  end
                  td(
                    class:
                      "whitespace-nowrap px-6 py-4 text-right text-sm text-gray-500"
                  ) do
                    span(class: "font-medium text-gray-900") { "$20,000" }
                    plain " USD"
                  end
                  td(
                    class:
                      "hidden whitespace-nowrap px-6 py-4 text-sm text-gray-500 md:block"
                  ) do
                    span(
                      class:
                        "inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium capitalize text-green-800"
                    ) { "success" }
                  end
                  td(
                    class:
                      "whitespace-nowrap px-6 py-4 text-right text-sm text-gray-500"
                  ) { time(datetime: "2020-07-11") { "July 11, 2020" } }
                end
                comment { "More transactions..." }
              end
            end
            comment { "Pagination" }
            nav(
              class:
                "flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6",
              aria_label: "Pagination"
            ) do
              div(class: "hidden sm:block") do
                p(class: "text-sm text-gray-700") do
                  plain " Showing "
                  span(class: "font-medium") { "1" }
                  plain " to "
                  span(class: "font-medium") { "10" }
                  plain " of "
                  span(class: "font-medium") { "20" }
                  plain " results"
                end
              end
              div(
                class: "flex flex-1 justify-between gap-x-3 sm:justify-end"
              ) do
                a(
                  href: "#",
                  class:
                    "relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:ring-gray-400"
                ) { "Previous" }
                a(
                  href: "#",
                  class:
                    "relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:ring-gray-400"
                ) { "Next" }
              end
            end
          end
        end
      end
    end
  end
end
