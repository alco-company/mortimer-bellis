class ActivityList < Phlex::HTML
  def initialize(list:, url:)
    @list = list
    @url = url
  end

  def view_template
    comment { "Activity section" }
    h2(
      class:
        "mx-auto mt-8 max-w-6xl px-4 text-lg font-medium leading-6 text-gray-900 sm:px-6 lg:px-8"
    ) { I18n.t("landing.recent_activity") }

    comment { "Activity list (smallest breakpoint only)" }
    #
    # due to TailwindCSS not being to pickup the mort-state-* classes
    # we introduce them here:
    div(class: "hidden mort-state-in mort-state-out mort-state-break mort-state-sick mort-state-iam_sick mort-state-child_sick mort-state-nursing_sick mort-state-lost_work_sick mort-state-p56_sick mort-state-free mort-state-rr_free mort-state-senior_free mort-state-unpaid_free mort-state-maternity_free mort-state-leave_free mort-state-archived") { }
    div(class: "shadow sm:hidden") do
      ul(role: "list", class: "mt-2 divide-y divide-gray-200 overflow-hidden shadow sm:hidden") do
        @list.each do |item|
          list_item(item: item)
        end
      end
      div(class: "bg-gray-50 px-5 py-3") do
        div(class: "text-sm") do
          a(
            href: @url,
            class: "font-medium text-cyan-700 hover:text-cyan-900"
          ) { I18n.t("view_all") }
        end
      end

      # nav(
      #   class:
      #     "flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3",
      #   aria_label: "Pagination"
      # ) do
      #   div(class: "flex flex-1 justify-between") do
      #     a(
      #       href: "#",
      #       class:
      #         "relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
      #     ) { "Previous" }
      #     a(
      #       href: "#",
      #       class:
      #         "relative ml-3 inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
      #     ) { "Next" }
      #   end
      # end
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
                  ) { I18n.t("landing.activity_list.transaction") }
                  th(
                    class:
                      "bg-gray-50 px-6 py-3 text-right text-sm font-semibold text-gray-900",
                    scope: "col"
                  ) { I18n.t("landing.activity_list.time") }
                  th(
                    class:
                      "hidden bg-gray-50 px-6 py-3 text-left text-sm font-semibold text-gray-900 md:block",
                    scope: "col"
                  ) { I18n.t("landing.activity_list.state") }
                  th(
                    class:
                      "bg-gray-50 px-6 py-3 text-right text-sm font-semibold text-gray-900",
                    scope: "col"
                  ) { I18n.t("landing.activity_list.date") }
                end
              end

              tbody(class: "divide-y divide-gray-200 bg-white") do
                @list.each do |item|
                  table_item(item: item)
                end
              end
            end
            comment { "Pagination" }
            div(class: "bg-gray-50 px-5 py-3") do
              div(class: "text-sm") do
                a(
                  href: @url,
                  class: "font-medium text-cyan-700 hover:text-cyan-900"
                ) { I18n.t("view_all") }
              end
            end

            # nav(
            #   class:
            #     "flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6",
            #   aria_label: "Pagination"
            # ) do
            #   div(class: "hidden sm:block") do
            #     p(class: "text-sm text-gray-700") do
            #       plain " Showing "
            #       span(class: "font-medium") { "1" }
            #       plain " to "
            #       span(class: "font-medium") { "10" }
            #       plain " of "
            #       span(class: "font-medium") { "20" }
            #       plain " results"
            #     end
            #   end
            #   div(
            #     class: "flex flex-1 justify-between gap-x-3 sm:justify-end"
            #   ) do
            #     a(
            #       href: "#",
            #       class:
            #         "relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:ring-gray-400"
            #     ) { "Previous" }
            #     a(
            #       href: "#",
            #       class:
            #         "relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:ring-gray-400"
            #     ) { "Next" }
            #   end
            # end
          end
        end
      end
    end
  end

  def list_item(item:)
    li do
      a(href: helpers.url_for(item), class: "block bg-white px-4 py-4 hover:bg-gray-50") do
        span(class: "flex items-center space-x-4") do
          span(class: "flex flex-1 space-x-2 truncate") do
            punch_clock_svg
            span(class: "flex flex-col truncate text-sm text-gray-500") do
              span(class: "truncate") { I18n.t("landing.activity_description", name: item.employee.name, punch_clock: item.punch_clock.name) }
              span do
                span(class: "font-medium text-gray-900 mr-2") { I18n.l(item.punched_at, format: :ultra_short) }
                plain WORK_STATE_H[item.state]
              end
              time(datetime: item.punched_at) { I18n.l(item.punched_at, format: :date) }
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
  end

  def table_item(item:)
    tr(class: "bg-white") do
      td(
        class:
          "w-full max-w-0 whitespace-nowrap px-6 py-4 text-sm text-gray-900"
      ) do
        div(class: "flex") do
          a(
            href: helpers.url_for(item),
            class: "group inline-flex space-x-2 truncate text-sm"
          ) do
              punch_clock_svg
            p(
              class:
                "truncate text-gray-500 group-hover:text-gray-900"
            ) { I18n.t("landing.activity_description", name: item.employee.name, punch_clock: item.punch_clock.name) }
          end
        end
      end
      td(
        class:
          "whitespace-nowrap px-6 py-4 text-right text-sm text-gray-500"
      ) do
        span(class: "font-medium text-gray-900") { I18n.l(item.punched_at, format: :ultra_short) }
      end
      td(
        class:
          "hidden whitespace-nowrap px-6 py-4 text-sm text-gray-500 md:block"
      ) do
        span(
          class:
            "inline-flex items-center rounded-full mort-state-#{item.state} px-2.5 py-0.5 text-xs font-medium capitalize"
        ) { WORK_STATE_H[item.state] }
      end
      td(
        class:
          "whitespace-nowrap px-6 py-4 text-right text-sm text-gray-500"
      ) { time(datetime: item.punched_at) { I18n.l(item.punched_at, format: :date) } }
    end
  end

  def punch_clock_svg
    svg(
      class: "pr-1 text-gray-300 h-6 w-6 ml-2",
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
