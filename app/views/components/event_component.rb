class EventComponent < ApplicationComponent
  def view_template
    div(class: "flex flex-col gap-y-2 divide-y-2 divide-gray-100") do
      event_type_selecter
      simple_punch
      advanced_work_schedule
      appointment
      holiday_event
    end
  end

  def event_type_selecter
    div(class: "mt-4 sm:grid sm:grid-cols-3 sm:justify-items-stretch") do
      label(for: "location", class: "block text-sm font-medium leading-6 text-gray-900 sm:place-content-center") { "Aftale" }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        select(id: "location", name: "location", class: "block w-full rounded-md border-0 py-1.5 pl-3 pr-10 text-gray-900 ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm sm:leading-6") do
          option(selected: "selected") { "Arbejdstid - enkelt" }
          option { "Arbejdstid - skabelon" }
          option { "Opgave" }
          option { "Møde" }
          option { "Helligdag" }
        end
      end
    end
  end

  # simple punch
  def simple_punch
    div(id: "work_schedule_simple", class: "") do
      # comment { "work type" }
      div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900") { "Arbejdstidstype" }
        div(class: "mt-2 sm:col-span-2 sm:mt-0") do
          div(class: "flex sm:max-w-md sm:place-content-end") do
            div(class: "gap-y1 grid grid-flow-row-dense grid-cols-3 grid-rows-2 justify-items-center gap-x-4") do
              div(class: "self-center text-xs font-medium") { "Arbejde" }
              div(class: "self-center text-xs font-medium") { "Syg" }
              div(class: "self-center text-xs font-medium") { "Fri" }
              button(
                type: "button",
                data_action: " click->pos-employee#toggleWork",
                data_pos_employee_target: "workButton",
                class:
                  "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
                role: "switch",
                aria_checked: "true"
              ) do
                span(class: "sr-only") { "work" }
                span(data_pos_employee_target: "workSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
              end
              button(
                type: "button",
                data_action: " click->pos-employee#toggleSick",
                data_pos_employee_target: "sickButton",
                class:
                  "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
                role: "switch",
                aria_checked: "false"
              ) do
                span(class: "sr-only") { "sick" }
                span(data_pos_employee_target: "sickSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
              end
              button(
                type: "button",
                data_action: " click->pos-employee#toggleFree",
                data_pos_employee_target: "freeButton",
                class:
                  "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
                role: "switch",
                aria_checked: "false"
              ) do
                span(class: "sr-only") { "free" }
                span(data_pos_employee_target: "freeSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
              end
              input(id: "in", name: "punch[reason]", type: "radio", data_pos_employee_target: "workReason", value: "in", checked: "checked", class: "hidden")
            end
          end
        end
      end

      start_date_time_field
      end_date_time_field
      # comment { %(start from_date only visible on single "punch") }
      # div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      #   label(for: "from_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Fra kl" }
      #   div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
      #     input(name: "punch[from_date]", id: "from_date", type: "date", data_pos_employee_target: "fromDate", autofocus: "", class: "mort-form-text mr-2 max-w-44")
      #     input(name: "punch[from_time]", id: "from_time", type: "time", data_pos_employee_target: "fromTime", autofocus: "", class: "mort-form-text max-w-28")
      #   end
      # end
      # comment { %(stop end_date only visible on single "punch") }
      # div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      #   label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Til kl" }
      #   div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
      #     input(name: "punch[end_date]", id: "end_date", type: "date", data_pos_employee_target: "endDate", autofocus: "", class: "mort-form-text mr-2 max-w-44", disabled: "disabled")
      #     input(name: "punch[end_time]", id: "end_time", type: "time", data_pos_employee_target: "endTime", autofocus: "", class: "mort-form-text max-w-28")
      #   end
      # end
      # comment { "duration" }
      duration_field
      # div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      #   label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Varighed" }
      #   div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
      #     input(name: "punch[duration]", id: "punch_duration", type: "number", data_pos_employee_target: "duration", autofocus: "", class: "mort-form-text max-w-24")
      #   end
      # end
      # comment { "breaks" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Pauser" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(name: "punch[breaks]", id: "punch_breaks", type: "number", data_pos_employee_target: "breaks", autofocus: "", class: "mort-form-text mr-4 max-w-24 sm:mr-0")
        end
        div(class: "mt-2 flex sm:col-span-2 sm:col-start-2 sm:place-content-end") do
          label(class: "mr-2") { "Inkl i varighed" }
          button(
            type: "button",
            data_action: " click->pos-employee#toggleFree",
            data_pos_employee_target: "freeButton",
            class:
              "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
            role: "switch",
            aria_checked: "false"
          ) do
            span(class: "sr-only") { "free" }
            span(data_pos_employee_target: "freeSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
          end
          input(id: "in", name: "punch[reason]", type: "radio", data_pos_employee_target: "workReason", value: "in", checked: "checked", class: "hidden")
        end
      end
      comment_field
      attachment_field
    end
  end

  def advanced_work_schedule
    div(id: "work_schedule_advanced", class: "hidden") do
      # comment { "schedule subject/title" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        whitespace
        label(
          for: "excluded_days",
          class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
        ) { "Navn på plan" }
        div(class: "mt-2 sm:col-span-2 sm:mt-0") do
          input(
            name: "punch[excluded_days]",
            id: "punch_excluded_days",
            data_pos_employee_target: "excluded_days",
            class: "mort-form-text"
          )
        end
      end

      # comment { "work type" }
      div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900") { "Arbejdstidstype" }
        div(class: "mt-2 sm:col-span-2 sm:mt-0") do
          div(class: "flex sm:max-w-md sm:place-content-end") do
            div(class: "gap-y1 grid grid-flow-row-dense grid-cols-3 grid-rows-2 justify-items-center gap-x-4") do
              div(class: "self-center text-xs font-medium") { "Arbejde" }
              div(class: "self-center text-xs font-medium") { "Syg" }
              div(class: "self-center text-xs font-medium") { "Fri" }
              button(type: "button", data_action: " click->pos-employee#toggleWork", data_pos_employee_target: "workButton", class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600", role: "switch", aria_checked: "true") do
                span(class: "sr-only") { "work" }
                span(data_pos_employee_target: "workSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
              end
              button(type: "button", data_action: " click->pos-employee#toggleSick", data_pos_employee_target: "sickButton", class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600", role: "switch", aria_checked: "false") do
                span(class: "sr-only") { "sick" }
                span(data_pos_employee_target: "sickSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
              end
              button(type: "button", data_action: " click->pos-employee#toggleFree", data_pos_employee_target: "freeButton", class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600", role: "switch", aria_checked: "false") do
                span(class: "sr-only") { "free" }
                span(data_pos_employee_target: "freeSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
              end
              input(id: "in", name: "punch[reason]", type: "radio", data_pos_employee_target: "workReason", value: "in", checked: "checked", class: "hidden")
            end
          end
        end
      end

      # comment { "autoPunch only visible on work_schedule" }
      div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900") { "Lad Mortimer stemple din arbejdstid" }
        div(class: "mt-2 sm:col-span-2 sm:mt-0") do
          div(class: "flex sm:max-w-md sm:place-content-end") do
            div(class: "gap-y1 grid grid-flow-row-dense grid-cols-1 grid-rows-2 justify-items-center gap-x-4") do
              div(class: "self-center text-xs font-medium") { "Automatisk stempling" }
              button(
                type: "button",
                data_action: " click->pos-employee#toggleAutoPunch",
                data_pos_employee_target: "autoPunchButton",
                class:
                  "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
                role: "switch",
                aria_checked: "true"
              ) do
                span(class: "sr-only") { "auto punch" }
                span(
                  data_pos_employee_target: "autoPunchSpan",
                  aria_hidden: "true",
                  class:
                    "pointer-events-none inline-block h-5 w-5 translate-x-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                )
              end
              input(
                id: "in",
                name: "work_schedule[auto_punch]",
                type: "radio",
                data_pos_employee_target: "autoPunch",
                value: "in",
                checked: "checked",
                class: "hidden"
              )
            end
          end
        end
      end

      # comment { %(start from_date only visible on single "punch") }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(
          for: "from_at",
          class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
        ) { "Fra kl" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(
            name: "punch[from_date]",
            id: "from_date",
            type: "date",
            data_pos_employee_target: "fromDate",
            autofocus: "",
            class: "mort-form-text mr-2 max-w-44"
          )
          input(
            name: "punch[from_time]",
            id: "from_time",
            type: "time",
            data_pos_employee_target: "fromTime",
            autofocus: "",
            class: "mort-form-text max-w-28"
          )
        end
      end

      # comment { %(stop end_date only visible on single "punch") }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(
          for: "end_at",
          class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
        ) { "Til kl" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(
            name: "punch[end_date]",
            id: "end_date",
            type: "date",
            data_pos_employee_target: "endDate",
            autofocus: "",
            class: "mort-form-text mr-2 max-w-44"
          )
          input(
            name: "punch[end_time]",
            id: "end_time",
            type: "time",
            data_pos_employee_target: "endTime",
            autofocus: "",
            class: "mort-form-text max-w-28"
          )
        end
      end

      # comment { "duration" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Varighed" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(name: "punch[duration]", id: "punch_duration", type: "number", data_pos_employee_target: "duration", autofocus: "", class: "mort-form-text max-w-24")
        end
      end

      # comment { "breaks" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Pauser" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(name: "punch[breaks]", id: "punch_breaks", type: "number", data_pos_employee_target: "breaks", autofocus: "", class: "mort-form-text mr-4 max-w-24 sm:mr-0")
        end
        div(class: "mt-2 flex sm:col-span-2 sm:col-start-2 sm:place-content-end") do
          label(class: "mr-2") { "Inkl i varighed" }
          button(
            type: "button",
            data_action: " click->pos-employee#toggleFree",
            data_pos_employee_target: "freeButton",
            class:
              "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
            role: "switch",
            aria_checked: "false"
          ) do
            whitespace
            span(class: "sr-only") { "free" }
            whitespace
            span(
              data_pos_employee_target: "freeSpan",
              aria_hidden: "true",
              class:
                "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
            )
            whitespace
          end
          input(
            id: "in",
            name: "punch[reason]",
            type: "radio",
            data_pos_employee_target: "workReason",
            value: "in",
            checked: "checked",
            class: "hidden"
          )
        end
      end

      # comment { "advanced scheduling starts here" }
      hr
      h3(class: "text-md mt-5") { "Gentagelser" }

      # comment { %(start from_date only visible on single "punch") }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "from_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Fra dato" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(
            name: "punch[from_date]",
            id: "from_date",
            type: "date",
            data_pos_employee_target: "fromDate",
            autofocus: "",
            class: "mort-form-text mr-2 max-w-44"
          )
        end
      end

      # comment { %(stop end_date only visible on single "punch") }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Til dato" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(name: "punch[end_date]", id: "end_date", type: "date", data_pos_employee_target: "endDate", autofocus: "", class: "mort-form-text mr-2 max-w-44")
        end
      end
      p(class: "text-gray-300") do
        "Hvis blot én af betingelserne her nedenfor er opfyldt, træder denne plan i kraft"
      end

      # comment { "daily" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        div(class: "col-span-3 flex border-b sm:col-span-1 sm:flex-row-reverse sm:place-items-center sm:border-0") do
          label(for: "end_at", class: "flex-grow text-sm font-medium leading-6 text-gray-900 sm:ml-1") { "Dagligt" }
          svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewbox: "0 -960 960 960", width: "24px", fill: "#5f6368") do |s|
            s.path(d: "M480-120 300-300l58-58 122 122 122-122 58 58-180 180ZM358-598l-58-58 180-180 180 180-58 58-122-122-122 122Z")
          end
        end
        fieldset(class: "mt-2 flex sm:col-span-2 hidden") do
          legend(class: "sr-only") { "Dagligt" }
          div(class: "relative flex items-center") do
            div(class: "flex") do
              input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0")
            end
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900") { "interval" }
              span(id: "comments-description", class: "text-gray-500") do
                span(class: "sr-only") { "interval " }
                plain "i dage mellem aftalens ikrafttræden."
              end
            end
          end
        end
      end

      # comment { "weekly" }
      div(class: "my-4 sm:grid sm:grid-cols-4 sm:items-start") do
        div(class: "col-span-4 flex sm:col-span-2 sm:flex-row-reverse sm:place-items-center border-b sm:border-0") do
          label(for: "end_at", class: "flex-grow text-sm font-medium leading-6 text-gray-900 sm:ml-1") { "Ugentligt" }
          svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewbox: "0 -960 960 960", width: "24px", fill: "#5f6368") do |s|
            s.path(d: "m356-160-56-56 180-180 180 180-56 56-124-124-124 124Zm124-404L300-744l56-56 124 124 124-124 56 56-180 180Z")
          end
        end
        div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
          div(class: "ml-3 text-sm leading-5") do
            label(for: "comments", class: "font-medium text-gray-900 mr-2") { "Gentages hver" }
          end
          div(class: "flex") do
            input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0 w-12")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "comments", class: "font-medium text-gray-900") { "dag" }
          end
        end
        fieldset(class: "mt-2 flex col-span-4 place-content-stretch hidden") do
          legend(class: "sr-only") { "Ugentligt" }
          div(class: "grid grid-cols-3 sm:grid-cols-4 gap-x-2 w-full") do
            %w[mandag tirsdag onsdag torsdag fredag lørdag søndag].each do |day|
              div(class: "flex items-start") do
                div(class: "flex h-6 items-center") do
                  input(id: "comments", aria_describedby: "comments-description", name: "comments", type: "checkbox", class: "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600")
                end
                div(class: "ml-3 text-sm leading-6") do
                  span(class: "sr-only") { day }
                  label(for: "comments", class: "font-medium text-gray-900") { day }
                end
              end
            end
          end
        end
      end

      # comment { "monthly" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        div(class: "col-span-3 flex border-b sm:col-span-1 sm:flex-row-reverse sm:place-items-center sm:border-0") do
          label(for: "end_at", class: "flex-grow text-sm font-medium leading-6 text-gray-900 sm:ml-1") { "Månedligt" }
          svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewbox: "0 -960 960 960", width: "24px", fill: "#5f6368") do |s|
            s.path(d: "M480-120 300-300l58-58 122 122 122-122 58 58-180 180ZM358-598l-58-58 180-180 180 180-58 58-122-122-122 122Z")
          end
        end
        fieldset(class: "mt-2 grid col-span-3 sm:col-span-2 hidden") do
          legend(class: "sr-only") { "Månedligt" }
          div(class: "flex items-center col-span-2 mt-2") do
            div(class: "flex") do
              input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0")
            end
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900") { "dag(e)" }
              span(id: "comments-description", class: "text-gray-500") do
                span(class: "sr-only") { "dag(e) " }
                plain "i måneden"
              end
            end
          end
          div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
            div(class: "flex items-center") do
              div(class: "text-sm leading-5 h-3") do
                label(for: "comments", class: "font-medium text-gray-900 mr-2") { "den" }
              end
              div(class: "flex mr-2") do
                input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text w-12")
              end
            end
            div(class: "flex items-center") do
              select(id: "ugedag", name: "ugedag", class: "mort-form-text w-32") do
                option(selected: "selected") { "mandag" }
                option { "tirsdag" }
                option { "onsdag" }
                option { "tordag" }
                option { "fredag" }
                option { "lørdag" }
                option { "søndag" }
              end
            end
          end
          div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
            div(class: "text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2") { "for hver" }
            end
            div(class: "flex") do
              input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0 w-12")
            end
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2") { "måned(er)" }
            end
          end
        end
      end

      # comment { "yearly" }
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        div(class: "col-span-3 flex border-b sm:col-span-1 sm:flex-row-reverse sm:place-items-center sm:border-0") do
          label(for: "end_at", class: "flex-grow text-sm font-medium leading-6 text-gray-900 sm:ml-1") { "Årligt" }
          svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewbox: "0 -960 960 960", width: "24px", fill: "#5f6368") do |s|
            s.path(d: "M480-120 300-300l58-58 122 122 122-122 58 58-180 180ZM358-598l-58-58 180-180 180 180-58 58-122-122-122 122Z")
          end
        end
        fieldset(class: "mt-2 grid col-span-3 sm:col-span-2") do
          legend(class: "sr-only") { "Årligt" }
          div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2") { "Gentages hvert" }
            end
            div(class: "flex") do
              input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0 w-12")
            end
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900") { "år" }
            end
          end
          div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
            div(class: "flex items-center") do
              div(class: "text-sm leading-5 h-3") do
                label(for: "comments", class: "font-medium text-gray-900 mr-2") { "den" }
              end
              div(class: "flex mr-2") do
                input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text w-12")
              end
            end
            div(class: "flex items-center") do
              select(id: "ugedag", name: "ugedag", class: "mort-form-text w-32") do
                option(selected: "selected") { "januar" }
                option { "februar" }
                option { "marts" }
                option { ".." }
                option { "december" }
              end
            end
          end
          div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
            div(class: "flex items-center") do
              div(class: "text-sm leading-5 h-3") do
                label(for: "comments", class: "font-medium text-gray-900 mr-2") { "på den" }
              end
              div(class: "flex mr-2") do
                input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text w-12")
              end
            end
            div(class: "flex items-center") do
              select(id: "ugedag", name: "ugedag", class: "mort-form-text w-32") do
                option(selected: "selected") { "mandag" }
                option { "tirsdag" }
                option { "onsdag" }
                option { "tordag" }
                option { "fredag" }
                option { "lørdag" }
                option { "søndag" }
              end
            end
          end
          div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
            div(class: "text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2") { "de næste" }
            end
            div(class: "flex") do
              input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0 w-12")
            end
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2") { "år, startende i" }
            end
            div(class: "flex") do
              input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0 w-20")
            end
            div(class: "ml-3 text-sm leading-5") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2") { "??" }
            end
          end
        end
      end

      # comment { "dates excluded" }
      div do
        label(for: "comment", class: "block text-sm font-medium leading-6 text-gray-900") { "Undtaget følgende datoer" }
        div(class: "mt-2") do
          input(id: "schedule_daily", aria_describedby: "comments-description", name: "schedule[daily]", class: "mort-form-text mt-0 w-full")
        end
      end
      comment_field
      attachment_field
    end
  end

  def appointment
    # comment { "aftale" }
    div(id: "appointment", class: "hidden") do
      name_field "Titel / Overskrift på aftalen/opgaven"
      all_day_field "Varer aftalen hele dagen?"
      start_date_time_field
      end_date_time_field
      duration_field
      comment_field
      attachment_field
    end
  end

  # comment { "helligdag" }
  def holiday_event
    div(id: "holiday", class: "hidden") do
      name_field I18n.t("event.holiday_lbl")
      all_day_field "Er helligdagen en hel fridag?"
      start_date_time_field
      end_date_time_field
      comment_field
      attachment_field
    end
  end

  # field methods ----------------

  # comment { "name of day" }
  def name_field(lbl)
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "excluded_days", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { lbl }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        input(name: "punch[excluded_days]", id: "punch_excluded_days", data_pos_employee_target: "excluded_days", class: "mort-form-text")
      end
    end
  end

  # comment { "start from_time only visible on non-all_day appointments" }
  def start_date_time_field
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(
        for: "from_at",
        class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
      ) { "Fra kl" }
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
        input(name: "punch[from_date]", id: "from_date", type: "date", data_pos_employee_target: "fromDate", autofocus: "", class: "mort-form-text mr-2 max-w-44")
        input(name: "punch[from_time]", id: "from_time", type: "time", data_pos_employee_target: "fromTime", autofocus: "", class: "mort-form-text max-w-28")
      end
    end
  end
  # comment { "stop end_time only visible on non-all_day appointments" }
  def end_date_time_field
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { "Til kl" }
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
        input(name: "punch[end_date]", id: "end_date", type: "date", data_pos_employee_target: "endDate", autofocus: "", class: "mort-form-text mr-2 max-w-44")
        input(name: "punch[end_time]", id: "end_time", type: "time", data_pos_employee_target: "endTime", autofocus: "", class: "mort-form-text max-w-28")
      end
    end
  end

  # comment { "all_day" }
  def all_day_field(lbl)
    div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900") { lbl }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        div(class: "flex sm:max-w-md sm:place-content-end") do
          div(class: "gap-y1 grid grid-flow-row-dense grid-cols-1 grid-rows-2 justify-items-center gap-x-4") do
            div(class: "self-center text-xs font-medium") { "hele dagen" }
            button(
              type: "button",
              data_action: " click->pos-employee#toggleAllDay",
              data_pos_employee_target: "allDayButton",
              class:
                "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
              role: "switch",
              aria_checked: "true"
            ) do
              span(class: "sr-only") { "all day" }
              span(data_pos_employee_target: "allDaySpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 translate-x-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
            end
            input(id: "in", name: "appointment[all_day]", type: "radio", data_pos_employee_target: "allDay", value: "in", checked: "checked", class: "hidden")
          end
        end
      end
    end
  end

  # comment { "duration" }
  def duration_field
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(
        for: "end_at",
        class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
      ) do
        "Varighed (angiv evt. t:m pr dag hvis aftalen strækker sig over flere dage)"
      end
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
        input(
          name: "punch[duration]",
          id: "punch_duration",
          type: "number",
          data_pos_employee_target: "duration",
          autofocus: "",
          class: "mort-form-text max-w-24"
        )
      end
    end
  end

  # comment { "comments" }
  def comment_field
    div do
      label(for: "comment", class: "block text-sm font-medium leading-6 text-gray-900") { "Bemærkninger/Kommentarer/Detaljer" }
      div(class: "mt-2") do
        textarea(rows: "4", name: "comment", id: "comment", class: "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6")
      end
    end
  end

  # comment { "attachments" }
  def attachment_field
    div(class: "mort-field") do
      label(for: "user_mugshot") { "Bilag" }
      br
      input(class: "mort-form-file", type: "file", name: "user[mugshot]", id: "user_mugshot")
    end
  end
end
