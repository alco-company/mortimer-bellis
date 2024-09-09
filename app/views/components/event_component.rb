#
#
class EventComponent < ApplicationComponent
  attr_accessor :resource, :resource_class, :list

  def initialize(resource: nil)
    @resource = resource
  end

  def view_template
    div(class: "flex flex-col", data: { controller: "tabs", tabs_index: "0" }) do
      event_tab_selector
      show_task_tab
      show_work_tab
      show_recurring_tab
      show_notes_tab
    end
  end

  def event_tab_selector
    div do
      div(class: "sm:hidden") do
        label(for: "tabs", class: "sr-only") { "Select a tab" }
        select(data: { action: "tabs#change" }, class: "block w-full rounded-md border-gray-300 focus:border-sky-500 focus:ring-sky-500") do
          option(value: 0, selected: "selected") { "Work" }
          option(value: 1) { "Task" }
          option(value: 2) { "Recurring" }
          option(value: 3) { "Notes" }
        end
      end
      div(class: "hidden sm:block") do
        div(class: "border-b border-gray-200") do
          nav(class: "-mb-px flex", aria_label: "Tabs") do
            # comment do %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 0,
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.type.task") }
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 1,
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.type.work") }
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 2,
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.type.schedule") }
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 3,
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.type.notes") }
          end
        end
      end
    end
  end

  def show_task_tab
    div(data: { tabs_target: "tabPanel" }) do
      name_field I18n.t("event.task_name") # "Titel / Overskrift på opgaven"
      color_field
      start_date_time_field
      end_date_time_field()

      # comment { "duration" }
      duration_field
      all_day_field I18n.t("event.all_day_event") # "Varer aftalen hele dagen?"
    end
  end

  def show_work_tab
    div(data: { tabs_target: "tabPanel" }) do
      let_mortimer_punch
      div(id: "work_details", class: "#{resource.auto_punch ? "" : "hidden"}") do
        # comment { "work type" }
        work_type_field

        # comment { "breaks" }
        set_work_options

        reason = resource.work_type == "in" ? "" : resource.reason
        # set the free Options
        set_options(reason: "free", label: helpers.t(".free_reason"), reasons: %w[rr_free senior_free unpaid_free maternity_free leave_free], value: reason)

        # set the sick Options
        set_options(reason: "sick", label: helpers.t(".sick_reason"), reasons: %w[iam_sick child_sick nursing_sick lost_work_sick p56_sick], value: reason)
      end
    end
  end

  def show_recurring_tab
    div(id: "recurring", data: { tabs_target: "tabPanel" }, class: "event-type recurring tab hidden") do
      # start_date_time_field(time_visible: false)
      # end_date_time_field(time_visible: false)

      p(class: "text-gray-300") do
        "Hvis blot én af betingelserne her nedenfor er opfyldt, træder denne plan i kraft"
      end


      div(data: { controller: "tabs", tabs_index: "0" }) do
        show_period_tabs
        show_daily_inputs
        show_weekly_inputs
        show_monthly_inputs
        show_yearly_inputs
      end

      # dates excluded
      # div(class: "mort-field") do
      #   label(for: "event_excluded_days", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("event.weekly.excluded_days") }
      #   div(class: "mt-2") do
      #     input(id: "event_excluded_days", aria_describedby: "comments-description", name: "event[excluded_days]", class: "mort-form-text mt-0 w-full")
      #   end
      # end
    end
  end

  def show_notes_tab
    div(id: "notes", data: { tabs_target: "tabPanel" }, class: "event-type notes tab hidden") do
      comment_field
      attachment_field
    end
  end

  # field methods ----------------

  def work_type_field
    div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900 self-center") { I18n.t("event.work_type") }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        div(class: "flex sm:max-w-md sm:place-content-end") do
          div(class: "gap-y1 grid grid-flow-row-dense grid-cols-3 grid-rows-2 justify-items-center gap-x-4") do
            div(class: "self-center text-xs font-medium") { "Arbejde" }
            div(class: "self-center text-xs font-medium") { "Syg" }
            div(class: "self-center text-xs font-medium") { "Fri" }
            button(
              type: "button",
              data_action: " click->event-form#toggleWork",
              data_event_form_target: "workButton",
              class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
              role: "switch",
              aria_checked: work_type_value("in", "true", "false")
            ) do
              span(class: "sr-only") { "work" }
              span(data_event_form_target: "workSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 #{work_type_value("in", "translate-x-5", "translate-x-0")} transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
            end
            button(
              type: "button",
              data_action: " click->event-form#toggleSick",
              data_event_form_target: "sickButton",
              class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
              role: "switch",
              aria_checked: work_type_value("sick", "true", "false")
            ) do
              span(class: "sr-only") { "sick" }
              span(data_event_form_target: "sickSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5  #{work_type_value("sick", "translate-x-5", "translate-x-0")} transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
            end
            button(
              type: "button",
              data_action: " click->event-form#toggleFree",
              data_event_form_target: "freeButton",
              class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
              role: "switch",
              aria_checked: work_type_value("free", "true", "false")
            ) do
              span(class: "sr-only") { "free" }
              span(data_event_form_target: "freeSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5  #{work_type_value("free", "translate-x-5", "translate-x-0")} transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
            end
            input(id: "event_work_type", name: "event[work_type]", type: "text", data_event_form_target: "workReason", value: resource.work_type, class: "hidden")
          end
        end
      end
    end
  end

  def work_type_value(type, true_value, false_value)
    resource.work_type==type ? true_value : false_value
  end

  # options for work
  def set_work_options
    div(class: work_type_value("in", "", "hidden"), data: { event_form_target: "workOptions" }) do
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5 self-center") { "Pauser" }
        div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
          input(name: "event[break_minutes]", id: "event_break_minutes", type: "number", data_event_form_target: "breakMinutesInput", autofocus: "", value: resource.break_minutes, class: "mort-form-text mt-0 mr-4 max-w-24 sm:mr-0")
        end
        div(class: "mt-2 flex sm:col-span-2 sm:col-start-2 sm:place-content-end") do
          label(class: "mr-2 self-center") { "Inkl i varighed" }
          button(
            type: "button",
            data_action: " click->event-form#toggleBreakIncluded",
            data_event_form_target: "breaksIncludedButton",
            class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
            role: "switch",
            aria_checked: resource.breaks_included ? "true" : "false"
          ) do
            span(class: "sr-only") { "breakIncluded" }
            span(data_event_form_target: "breaksIncludedSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 #{ resource.breaks_included ? "translate-x-5" : "translate-x-0"} transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
          end
          input(id: "event_breaks_included", name: "event[breaks_included]", type: "checkbox", data_event_form_target: "breaksIncludedInput", value: resource.breaks_included ? "1" : "0", checked: "checked", class: "hidden")
        end
      end
    end
  end

  # options for sick and free
  def set_options(reason:, label:, reasons:, value: "")
    div(class: "#{ reasons.include?(value) ? "" : "hidden"}", data: { event_form_target: "#{reason}Options" }) do
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "punch_reason", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { label }
        div(class: "mt-2 sm:col-span-2 sm:mt-0") do
          div(class: "flex sm:max-w-md") do
            div(class: "mt-4") do
              legend(class: "sr-only") { "#{reason} reasons" }
              div(class: "space-y-2") do
                reasons.each do |r|
                  chck = value == r
                  div(class: "flex items-center") do
                    input(
                      id: "#{reason}_punch_reason",
                      name: "event[reason]",
                      type: "radio",
                      value: r,
                      checked: chck,
                      class: "h-4 w-4 border-gray-300 text-sky-600 focus:ring-sky-600"
                    )
                    label(for: r, class: "ml-3 block text-sm font-medium leading-6 text-gray-900") { helpers.t(".#{r}") }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def let_mortimer_punch
    div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "reason", class: "block text-sm col-span-2 font-medium leading-6 text-gray-900 self-center") { "Lad Mortimer stemple din arbejdstid" }
      div(class: "mt-2 col-span-1 sm:mt-0") do
        div(class: "flex sm:max-w-md sm:place-content-end") do
          div(class: "gap-y1 grid grid-flow-row-dense grid-cols-1 justify-items-center gap-x-4") do
            # div(class: "self-center text-xs font-medium") { "Automatisk stempling" }
            button(
              type: "button",
              data_action: " click->event-form#toggleAutoPunch",
              data_event_form_target: "autoPunchButton",
              class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
              role: "switch",
              aria_checked: resource.auto_punch ? "true" : "false"
            ) do
              span(class: "sr-only") { "auto punch" }
              span(data_event_form_target: "autoPunchSpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 #{ resource.auto_punch ? "translate-x-5" : "translate-x-0" } transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
            end
            input(
              id: "event_auto_punch",
              name: "event[auto_punch]",
              type: "checkbox",
              data_event_form_target: "autoPunch",
              value: resource.auto_punch ? "1" : "0",
              checked: "checked",
              class: "hidden"
            )
          end
        end
      end
    end
  end

  # comment { "name of day" }
  def name_field(lbl)
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "event_name", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5 self-center") { lbl }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        input(name: "event[name]", type: "text", id: "event_name", class: "mort-form-text", autofocus: true, value: resource.name)
      end
    end
  end

  # comment { "name of day" }
  def color_field
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "event_name", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5 self-center") { plain I18n.t("activerecord.attributes.event.event_color") }
      render SelectComponent.new(resource: resource,
        field: :event_color,
        field_class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end",
        label_class: "hidden",
        value_class: "mt-2 sm:col-span-2 sm:mt-0",
        collection: Team.colors,
        show_label: false,
        prompt: I18n.t(".select_team_color"),
        editable: true)
    end
  end

  # comment { "start from_time only visible on non-all_day appointments" }
  def start_date_time_field(date_visible: true, time_visible: true)
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "from_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5 self-center") { I18n.t("event.from_at") }
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
        input(name: "event[from_date]", id: "event_from_date", type: "date", data_event_form_target: "fromDate", value: resource.from_date, class: "mort-form-text mt-0 max-w-44") if date_visible
        input(name: "event[from_time]", id: "event_from_time", type: "time", data_event_form_target: "fromTime", value: set_time(resource.from_time), class: "mort-form-text mt-0 ml-2 max-w-28") if time_visible
      end
    end
  end

  # comment { "stop end_time only visible on non-all_day appointments" }
  def end_date_time_field(date_visible: true, time_visible: true)
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "end_at", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5 self-center")  { I18n.t("event.to_at") }
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
        input(name: "event[to_date]", id: "event_to_date", type: "date", data_event_form_target: "toDate", value: resource.to_date, class: "mort-form-text mt-0 max-w-44") if date_visible
        input(name: "event[to_time]", id: "event_to_time", type: "time", data_event_form_target: "toTime", value: set_time(resource.to_time), class: "mort-form-text mt-0 ml-2 max-w-28") if time_visible
      end
    end
  end

  # comment { "all_day" }
  def all_day_field(lbl)
    div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900 sm:col-span-2 self-center") { lbl }
      div(class: "mt-2 sm:col-span-1 sm:mt-0") do
        div(class: "flex sm:max-w-md sm:place-content-end") do
          div(class: "gap-y1 grid grid-flow-row-dense grid-cols-1 grid-rows-2 justify-items-center gap-x-4") do
            div(class: "self-center text-xs font-medium") { "hele dagen" }
            button(
              type: "button",
              data_action: " click->event-form#toggleAllDay",
              data_event_form_target: "allDayButton",
              class: "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2 aria-checked:bg-sky-600",
              role: "switch",
              aria_checked: resource.all_day ? "true" : "false"
            ) do
              span(class: "sr-only") { "all day" }
              span(data_event_form_target: "allDaySpan", aria_hidden: "true", class: "pointer-events-none inline-block h-5 w-5 #{ resource.all_day ? "translate-x-5" : "translate-x-0" } transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out")
            end
            input(id: "event_all_day", name: "event[all_day]", type: "checkbox", data_event_form_target: "allDay", value: resource.all_day ? "1" : "0", checked: "checked", class: "hidden")
          end
        end
      end
    end
  end

  # comment { "duration" }
  def duration_field
    div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start", data: { event_form_target: "durationInput" }) do
      label(for: "event_duration", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5 self-center") { I18n.t("event.duration") } # "Varighed (angiv evt. t:m pr dag hvis aftalen strækker sig over flere dage)"
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0 sm:place-content-end") do
        input(name: "event[duration]", id: "event_duration", type: "text", data_event_form_target: "duration", class: "mort-form-text mt-0 max-w-24")
      end
    end
  end

  def show_daily_inputs
    div(class: "flex w-full", data: { tabs_target: "tabPanel" }) do
      # show_period_picker I18n.t("event.pickers.daily") # "col-span-3 flex border-b sm:col-span-1 sm:flex-row-reverse sm:place-items-center sm:border-0"
      div(id: "dailyInputs", class: "mt-2 tab grid grid-cols-1 gap-y-2") do
        legend(class: "sr-only") { "Dagligt" }
        div(class: "relative flex items-center") do
          div(class: "flex") do
            input(id: "event_event_metum_daily_interval", aria_describedby: "comments-description", name: "event[event_metum_attributes][daily_interval]", value: resource.get_field(:daily_interval), class: "mort-form-text w-20 mt-0")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "comments", class: "mr-2") { I18n.t("event.daily.label") }
            span(id: "comments-description", class: "text-gray-500") do
              span(class: "sr-only") { "interval " }
              plain I18n.t("event.daily.explain")
            end
          end
        end
        div(class: "relative flex items-center") do
          div(class: "flex items-center") do
            label(for: "comments", class: "mr-2") { I18n.t("event.daily.count") }
            input(id: "event_event_metum_days_count", aria_describedby: "comments-description", name: "event[event_metum_attributes][days_count]", value: resource.get_field(:days_count), class: "mort-form-text w-20 mt-0")
          end
          div(class: "ml-3 text-sm leading-5") do
            span(id: "comments-description", class: "text-gray-500") do
              span(class: "sr-only") { "count " }
              plain I18n.t("event.daily.counts_explain")
            end
          end
        end
      end
    end
  end

  def show_weekly_inputs
    div(class: "flex w-full", data: { tabs_target: "tabPanel" }) do
      # show_period_picker I18n.t("event.pickers.weekly") # , "col-span-4 flex sm:col-span-2 sm:flex-row-reverse sm:place-items-center border-b sm:border-0"
      div(id: "weeklyInputs", class: "mt-2 tab w-full") do
        div(class: "flex items-center mt-2 ") do
          div(class: "ml-3 text-sm leading-5") do
            label(for: "event_weekly_days", class: " mr-2")  { I18n.t("event.weekly.repeat") }
          end
          div(class: "flex") do
            input(id: "event_event_metum_weekly_interval", aria_describedby: "comments-description", name: "event[event_metum_attributes][weekly_interval]", value: resource.get_field(:weekly_interval), class: "mort-form-text mt-0 w-12")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "events_weekly_day", class: "") { I18n.t("event.weekly.day") }
          end
          div(class: "relative flex items-center ml-2") do
            div(class: "flex items-center") do
              label(for: "comments", class: "mr-2") { I18n.t("event.weekly.count.for") }
              input(id: "event_event_metum_weeks_count", aria_describedby: "comments-description", name: "event[event_metum_attributes][weeks_count]", value: resource.get_field(:weeks_count), class: "mort-form-text w-20 mt-0")
            end
            div(class: "ml-3 text-sm leading-5") do
              span(id: "comments-description", class: "text-gray-500") do
                span(class: "sr-only") { "count " }
                plain I18n.t("event.weekly.count.explain")
              end
            end
          end
        end
        div(class: "mt-2 ") do # flex col-span-3 place-content-stretch
          legend(class: "sr-only")  { I18n.t("event.weekly.week_day") }
          show_weekdays_inputs("weekly")
        end
      end
    end
  end

  def show_monthly_inputs
    div(class: "flex w-full", data: { tabs_target: "tabPanel" }) do
      # show_period_picker I18n.t("event.pickers.monthly") # "col-span-3 flex border-b sm:col-span-1 sm:flex-row-reverse sm:place-items-center sm:border-0"
      div(id: "monthlyInputs", class: "mt-2 tab w-full grid col-span-3 sm:col-span-2") do
        legend(class: "sr-only") { I18n.t("event.monthly.tab") }

        div(class: "flex items-center col-span-2 mt-2 sm:place-content-start") do
          div(class: "text-sm leading-5") do
            label(for: "events_monthly_every", class: "font-medium text-gray-900 mr-2")  { I18n.t("event.monthly.every_month.label") }
          end
          div(class: "flex") do
            input(id: "event_event_metum_monthly_interval", aria_describedby: "comments-description", name: "event[event_metum_attributes][monthly_interval]", value: resource.get_field(:monthly_interval), class: "mort-form-text mt-0 w-12")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "event_event_metum_monthly_interval", class: "font-medium text-gray-900 mr-2")  { I18n.t("event.monthly.every_month.explain") }
          end
          div(class: "flex") do
            input(id: "event_event_metum_monthly_count", aria_describedby: "comments-description", name: "event[event_metum_attributes][months_count]", value: resource.get_field(:months_count), class: "mort-form-text mt-0 w-12")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "event_event_metum_monthly_count", class: "font-medium text-gray-900 mr-2")  { I18n.t("event.monthly.every_month.count") }
          end
        end

        div(class: "flex items-center col-span-2 mt-2 ") do
          div(class: "flex items-center ") do
            label(for: "comments", class: "font-medium text-sm text-nowrap text-gray-500 mr-2") { I18n.t("event.monthly.days.label") } # "dag(e)" }
            input(id: "event_event_metum_monthly_days", aria_describedby: "comments-description", name: "event[event_metum_attributes][monthly_days]", value: resource.get_field(:monthly_days), class: "mort-form-text mt-0")
          end
          div(class: "ml-3 text-sm leading-5") do
            span(id: "comments-description", class: "text-gray-500") do
              span(class: "sr-only")  { I18n.t("event.monthly.days.label") }  # { "dag(e) " }
              plain I18n.t("event.monthly.days.explain") # "i måneden"
            end
          end
        end
        div(class: "flex items-center col-span-2 mt-2 ") do
          div(class: "flex items-center") do
            div(class: "text-sm leading-5 h-3") do
              label(for: "comments", class: "font-medium text-gray-900 mr-2")  { I18n.t("event.monthly.day.label") }
            end
            div(class: "flex mr-2") do
              input(id: "event_event_metum_monthly_dow", aria_describedby: "comments-description", name: "event[event_metum_attributes][monthly_dow]", value: resource.get_field(:monthly_dow), class: "mort-form-text w-12")
            end
          end
          show_weekdays_inputs("monthly")

          # div(class: "flex items-center") do
          #   select(id: "event_monthly_weekdays", name: "event[monthly_weekdays]", class: "mort-form-text w-32") do
          #     option { I18n.t("event.weekly.monday") }
          #     option { I18n.t("event.weekly.tuesday") }
          #     option { I18n.t("event.weekly.wednesday") }
          #     option { I18n.t("event.weekly.thursday") }
          #     option { I18n.t("event.weekly.friday") }
          #     option { I18n.t("event.weekly.saturday") }
          #     option { I18n.t("event.weekly.sunday") }
          #   end
          # end
        end
      end
    end
  end

  def show_yearly_inputs
    div(class: "flex w-full", data: { tabs_target: "tabPanel" }) do
      # show_period_picker I18n.t("event.pickers.yearly") #  "col-span-3 flex border-b sm:col-span-1 sm:flex-row-reverse sm:place-items-center sm:border-0"
      div(id: "yearlyInputs", class: "mt-2 tab grid col-span-3 w-full") do
        legend(class: "sr-only") { "Årligt" }
        div(class: "flex items-center col-span-2 mt-2") do
          div(class: "ml-3 text-sm leading-5") do
            label(for: "event_event_metum_yearly_interval", class: "text-nowrap font-medium text-gray-900 mr-2")  { I18n.t("event.yearly.repeat") } # { "Gentages hvert" }
          end
          div(class: "flex") do
            input(id: "event_event_metum_yearly_interval", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_interval]", value: resource.get_field(:yearly_interval), class: "mort-form-text mt-0 w-12")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "event_event_metum_yearly_interval", class: "font-medium text-gray-900") { I18n.t("event.yearly.year") }
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "event_event_metum_yearly_doy", class: "text-nowrap font-medium text-gray-900 mr-2")  { I18n.t("event.yearly.repeat_on_days_of_year") } # { "på følgende dage i året" }
          end
          div(class: "flex") do
            input(id: "event_event_metum_yearly_doy", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_doy]", value: resource.get_field(:yearly_doy), class: "mort-form-text mt-0 w-24")
          end
        end
        div(class: "flex items-center col-span-3 mt-2") do
          div(class: "flex items-center") do
            label(for: "event_event_metum_yearly_weeks", class: "text-nowrap mx-2 text-sm leading-5 text-gray-500") { I18n.t("event.yearly.for_the_weeks") }
            input(id: "event_event_metum_yearly_weeks", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_weeks]", value: resource.get_field(:yearly_weeks), class: "mort-form-text w-full mt-0")
          end
        end

        div(class: "flex items-center col-span-2 mt-2 ") do
          div(class: "flex items-center ") do
            label(for: "event_event_metum_yearly_days", class: "font-medium text-sm text-nowrap text-gray-500 mr-2") { I18n.t("event.monthly.days.label") } # "dag(e)" }
            input(id: "event_event_metum_yearly_days", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_days]", value: resource.get_field(:yearly_days), class: "mort-form-text mt-0")
          end
        end
        div(class: "flex items-center col-span-2 mt-2 ") do
          show_months_selected()
        end


        div(class: "flex items-center col-span-2 mt-2 ") do
          div(class: "flex items-center") do
            div(class: "text-sm leading-5 h-3") do
              label(for: "comments", class: "text-nowrap font-medium text-gray-900 mr-2") { I18n.t("event.yearly.on_weekday") }
            end
            div(class: "flex mr-2") do
              input(id: "event_event_metum_yearly_dows", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_dows]", value: resource.get_field(:yearly_dows), class: "mort-form-text w-12")
            end
          end
          show_weekdays_inputs("yearly")
        end
        div(class: "flex items-center col-span-2 mt-2 sm:place-content-end") do
          div(class: "text-sm leading-5") do
            label(for: "comments", class: "font-medium text-gray-900 mr-2") { I18n.t("event.yearly.next_years.label") }
          end
          div(class: "flex") do
            input(id: "event_event_metum_years_count", aria_describedby: "comments-description", name: "event[event_metum_attributes][years_count]", value: resource.get_field(:years_count), class: "mort-form-text mt-0 w-12")
          end
          div(class: "ml-3 text-sm leading-5") do
            label(for: "comments", class: "font-medium text-gray-900 mr-2") { I18n.t("event.yearly.next_years.explain") } # { "år, startende i" }
          end
          div(class: "flex") do
            input(id: "event_event_metum_yearly_next_years_start", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_next_years_start]", value: resource.get_field(:yearly_next_years_start), class: "mort-form-text mt-0 w-20")
          end
          # div(class: "ml-3 text-sm leading-5") do
          #   label(for: "comments", class: "font-medium text-gray-900 mr-2") { "??" }
          # end
        end
      end
    end
  end

  def show_weekdays_inputs(prefix)
    div(class: "grid grid-cols-3 sm:grid-cols-4 gap-x-2 w-full place-content-stretch ") do
      wd = resource.get_field("#{prefix}_weekdays".to_sym).keys rescue []
      %w[ monday tuesday wednesday thursday friday saturday sunday ].each do |day|
        chck = wd.include?(day)
        div(class: "flex items-start") do
          div(class: "flex h-6 items-center") do
            input(id: "event_#{prefix}_weekdays_#{day}", aria_describedby: "comments-description", name: "event[event_metum_attributes][#{prefix}_weekdays][#{day}]", type: "checkbox", value: day, checked: chck, class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600")
          end
          div(class: "ml-3 text-sm leading-6") do
            span(class: "sr-only") { day }
            label(for: "comments", class: "")  { I18n.t("event.#{prefix}.#{day}") }
          end
        end
      end
    end
  end

  def show_months_selected
    label(for: "comments", class: "text-nowrap text-sm mr-2") { I18n.t("event.yearly.months") }
    div(class: "flex items-center col-span-2 mt-2") do
      # div(class: "flex items-center") do
      #   div(class: "text-sm leading-5 h-3") do
      #   end
      # end
      div(class: "grid grid-cols-3 sm:grid-cols-4 gap-x-2 w-full place-content-stretch items-center") do
        wd = resource.get_field("yearly_months".to_sym).keys rescue []
        %w[ january february march april may june july august september october november december ].each do |mth|
          chck = wd.include?(mth)
          div(class: "flex items-start") do
            div(class: "flex h-6 items-center") do
              input(id: "event_event_metum_yearly_months_#{mth}", aria_describedby: "comments-description", name: "event[event_metum_attributes][yearly_months][#{mth}]", type: "checkbox", value: mth, checked: chck, class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600")
            end
            div(class: "ml-3 text-sm leading-6") do
              span(class: "sr-only") { mth }
              label(for: "event_event_metum_yearly_months_#{mth}", class: "")  { I18n.t("event.yearly.month.#{mth}") }
            end
          end
        end
      end
    end
  end

  def show_period_tabs
    div do
      div(class: "sm:hidden") do
        label(for: "tabs", class: "sr-only") { "Select a tab" }
        select(data: { action: "tabs#change" }, class: "block w-full rounded-md border-gray-300 focus:border-sky-500 focus:ring-sky-500") do
          option(value: 0) { I18n.t("event.daily.tab") }
          option(value: 1) { I18n.t("event.weekly.tab") }
          option(value: 2) { I18n.t("event.monthly.tab") }
          option(value: 3) { I18n.t("event.yearly.tab") }
        end
      end
      div(class: "hidden sm:block") do
        div(class: "border-b border-gray-200") do
          nav(class: "-mb-px flex", aria_label: "Tabs") do
            # comment do %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 0,
              # data_event_form_target: "workButton",
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.daily.tab") }
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 1,
              # data_event_form_target: "taskButton",
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.weekly.tab") }
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 2,
              # data_event_form_target: "recurringButton",
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.monthly.tab") }
            button(
              type: "button",
              data: { tabs_target: "tab", action: "tabs#change" },
              value: 3,
              # data_event_form_target: "notesButton",
              class: "tab-header w-1/4 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
              role: "switch",
              aria_checked: "false") { I18n.t("event.yearly.tab")  }
          end
        end
      end
    end
  end

  # comment { "comments" }
  def comment_field
    div(class: "mort-field") do
      label(for: "event_comment", class: "block text-sm font-medium leading-6 text-gray-900")  { I18n.t("event.comment") }
      div(class: "mt-2") do
        textarea(rows: "4", name: "event[comment]", id: "event_comment", class: "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-sky-600 sm:text-sm sm:leading-6")
      end
    end
  end

  # comment { "attachments" }
  def attachment_field
    div(class: "mort-field") do
      label(for: "event_files")  { I18n.t("event.bilag") }
      br
      input(class: "mort-form-file", type: "file", name: "event[files]", id: "event_files", multiple: "multiple")
    end
  end

  def set_time(tm)
    "%02d:%02d" % [ tm.hour, tm.min ]
  rescue
    "00:00"
  end
end

# simple punch
# def show_work_inputs
#   div(id: "work_inputs", data: { event_form_target: "workInputs" }, class: "event-type work") do
#     # comment { "work type" }
#     work_type_field

#     start_date_time_field
#     end_date_time_field()

#     # comment { "duration" }
#     duration_field

#     # comment { "breaks" }
#     set_work_options

#     # set the free Options
#     set_options(reason: "free", label: helpers.t(".free_reason"), reasons: %w[rr_free senior_free unpaid_free maternity_free leave_free])

#     # set the sick Options
#     set_options(reason: "sick", label: helpers.t(".sick_reason"), reasons: %w[iam_sick child_sick nursing_sick lost_work_sick p56_sick])

#     comment_field
#     attachment_field
#   end
# end

# def show_schedule_inputs
#   div(id: "schedule_inputs", data: { event_form_target: "scheduleInputs" }, class: "event-type schedule hidden") do
#     # comment { "schedule subject/title" }
#     name_field I18n.t("event.schedule_name")
#     work_type_field
#     let_mortimer_punch
#     start_date_time_field(date_visible: false)
#     end_date_time_field(date_visible: false)
#     duration_field

#     # comment { "breaks" }
#     set_work_options

#     # set the free Options
#     set_options(reason: "free", label: helpers.t(".free_reason"), reasons: %w[rr_free senior_free unpaid_free maternity_free leave_free])

#     # set the sick Options
#     set_options(reason: "sick", label: helpers.t(".sick_reason"), reasons: %w[iam_sick child_sick nursing_sick lost_work_sick p56_sick])

#     hr
#     h3(class: "text-md mt-5") { "Gentagelser" }

#     start_date_time_field(time_visible: false)
#     end_date_time_field(time_visible: false)

#     p(class: "text-gray-300") do
#       "Hvis blot én af betingelserne her nedenfor er opfyldt, træder denne plan i kraft"
#     end

#     ul(role: "list", class: "divide-y divide-gray-100 overflow-hidden bg-white shadow-sm ring-1 ring-gray-900/5 sm:rounded-xl") do
#       li(class: "relative cursor-pointer flex justify-between gap-x-6 px-4 py-5 hover:bg-gray-50 sm:px-6", data: { action: "click->event-form#togglePeriodPicker", type: "daily" }) do
#         show_daily_inputs
#       end
#       li(class: "relative cursor-pointer flex justify-between gap-x-6 px-4 py-5 hover:bg-gray-50 sm:px-6", data: { action: "click->event-form#togglePeriodPicker", type: "weekly" }) do
#         show_weekly_inputs
#       end
#       li(class: "relative cursor-pointer flex justify-between gap-x-6 px-4 py-5 hover:bg-gray-50 sm:px-6", data: { action: "click->event-form#togglePeriodPicker", type: "monthly" }) do
#         show_monthly_inputs
#       end
#       li(class: "relative cursor-pointer flex justify-between gap-x-6 px-4 py-5 hover:bg-gray-50 sm:px-6", data: { action: "click->event-form#togglePeriodPicker", type: "yearly" }) do
#         show_yearly_inputs
#       end
#    end

#     # dates excluded
#     # div(class: "mort-field") do
#     #   label(for: "comment", class: "block text-sm font-medium leading-6 text-gray-900") { "Undtaget følgende datoer" }
#     #   div(class: "mt-2") do
#     #     input(id: "event_excluded_dates", aria_describedby: "comments-description", name: "event[excluded_dates]", class: "mort-form-text mt-0 w-full")
#     #   end
#     # end

#     comment_field
#     attachment_field
#   end
# end

# def show_task_inputs
#   div(id: "task_inputs", data: { event_form_target: "taskInputs" }, class: "event-type task hidden") do
#     name_field I18n.t("event.task_name") # "Titel / Overskrift på opgaven"
#     # all_day_field "Varer aftalen hele dagen?"
#     start_date_time_field
#     end_date_time_field
#     duration_field
#     comment_field
#     attachment_field
#   end
# end

# def show_appointment_inputs
#   # comment { "aftale" }
#   div(id: "appointment_inputs", data: { event_form_target: "appointmentInputs" }, class: "event-type appointment hidden") do
#     name_field I18n.t("event.appointment_name") # "Titel / Overskrift på aftalen/opgaven"
#     all_day_field "Varer aftalen hele dagen?"
#     start_date_time_field
#     end_date_time_field
#     duration_field
#     comment_field
#     attachment_field
#   end
# end

# comment { "helligdag" }
# def show_holiday_inputs
#   div(id: "holiday_inputs", data: { event_form_target: "workInputs" }, class: "event-type holiday hidden") do
#     name_field I18n.t("event.holiday_name")
#     all_day_field "Er helligdagen en hel fridag?"
#     start_date_time_field
#     end_date_time_field
#     comment_field
#     attachment_field
#   end
# end
