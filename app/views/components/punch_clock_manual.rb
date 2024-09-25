class PunchClockManual < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :user

  def initialize(user: nil)
    @user = user || false
  end

  def view_template(&block)
    form_with id: "manualpunch", data: { pos_employee_target: "manualForm" }, url: helpers.pos_employee_url(api_key: user.access_token, tab: "payroll"), method: :post do
      div(class: "mx-4 my-2") do
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            helpers.t(".manuel_entry")
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            helpers.t(".manuel_entry_description")
          end
          # set the type of registration
          set_registration

          # set the time slot from_at
          from_at

          # set the time slot to_at
          to_at

          set_days
          set_excluded_days

          # set the comment
          set_comment

          # set the free Options
          set_options(reason: "free", label: helpers.t(".free_reason"), reasons: %w[rr_free senior_free unpaid_free maternity_free leave_free])

          # set the sick Options
          set_options(reason: "sick", label: helpers.t(".sick_reason"), reasons: %w[iam_sick child_sick nursing_sick lost_work_sick p56_sick])
        end
      end
    end
  end

  # def punch_in
  #   return if user.in?
  #   div(class: "justify-self-end") do
  #     button_tag helpers.t("+"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
  #     form_with url: helpers.pos_employee_url(api_key: user.access_token), id: "inform", method: :post do
  #       hidden_field :user, :api_key, value: user.access_token
  #       hidden_field :user, :state, value: :in
  #       hidden_field :user, :id, value: user.id
  #     end
  #   end
  # end

  def set_registration
    div(class: "mt-4 sm:grid sm:grid-cols-3 sm:items-start") do
      label(for: "reason", class: "block text-sm font-medium leading-6 text-gray-900") { helpers.t(".type_of_registration") }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        div(class: "flex sm:max-w-md") do
          div(class: "grid grid-flow-row-dense grid-cols-3 grid-rows-2 gap-x-4 gap-y1") do
            div(class: "text-xs font-medium") { helpers.t(".work") }
            div(class: "text-xs font-medium") { helpers.t(".sick") }
            div(class: "text-xs font-medium") { helpers.t(".free") }
            slider(action: "click->pos-employee#toggleWork", enabled: true, reason: "work")
            slider(action: "click->pos-employee#toggleSick", enabled: false, reason: "sick")
            slider(action: "click->pos-employee#toggleFree", enabled: false, reason: "free")
            input(
              id: "in",
              name: "punch[reason]",
              type: "radio",
              data: { pos_employee_target: "workReason" },
              value: "in",
              checked: "checked",
              class: "hidden"
            )
          end
        end
      end
    end
  end
  def from_at
    div(
      class: "my-4 sm:grid sm:grid-cols-3 sm:items-start"
    ) do
      label(
        for: "from_at",
        class:
          "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
      ) { helpers.t(".from_at") }
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0") do
        input(
          name: "punch[from_date]",
          id: "from_date",
          type: "date",
          data: { pos_employee_target: "fromDate" },
          autofocus: true,
          class:
            "mort-form-text max-w-44 mr-2"
        )
        input(
          name: "punch[from_time]",
          id: "from_time",
          type: "time",
          data: { pos_employee_target: "fromTime" },
          autofocus: true,
          class:
            "mort-form-text max-w-28"
        )
      end
    end
  end

  def to_at
    div(
      class: "my-4 sm:grid sm:grid-cols-3 sm:items-start"
    ) do
      whitespace
      label(
        for: "to_at",
        class:
          "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
      ) { helpers.t(".to_at") }
      div(class: "mt-2 flex sm:col-span-2 sm:mt-0") do
        input(
          name: "punch[to_date]",
          id: "to_date",
          type: "date",
          data: { pos_employee_target: "toDate" },
          autofocus: true,
          class:
            "mort-form-text max-w-44 mr-2"
        )
        input(
          name: "punch[to_time]",
          id: "to_time",
          type: "time",
          data: { pos_employee_target: "toTime" },
          autofocus: true,
          class:
            "mort-form-text max-w-28"
        )
      end
    end
  end

  def set_days
    fieldset(class: "w-full") do
      div(class: "flex text-base font-semibold leading-6 text-gray-900") do
        div(class: "w-1/2") { helpers.t("weekdays") }
        div(class: "w-1/2 cursor-pointer ", data: { action: "click->pos-employee#toggleWeekDays" }) do
          svg(class: "float-right", data: { pos_employee_target: "downArrow" }, xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s|
            s.path(d: "M480-344 240-584l56-56 184 184 184-184 56 56-240 240Z")
          end
          svg(class: "hidden float-right", data: { pos_employee_target: "upArrow" }, xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s|
            s.path(d: "M480-528 296-344l-56-56 240-240 240 240-56 56-184-184Z")
          end
        end
      end
      div(class: "hidden mt-4 divide-y divide-gray-200 border-b border-t border-gray-200", data: { pos_employee_target: "weekDays" }) do
        %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
          div(class: "relative flex items-start py-4") do
            div(class: "min-w-0 flex-1 text-sm leading-6") do
              label(
                for: "#{day}_checkbox",
                class: "select-none font-medium text-gray-900"
              ) { helpers.t(day) }
            end
            div(class: "ml-3 flex h-6 items-center") do
              input(id: "#{day}_checkbox", name: "punch[days][]", type: "checkbox", value: day, class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600", checked: (day != "saturday" && day != "sunday"))
            end
          end
        end
      end
    end
  end

  def set_excluded_days
    div(
      class: "my-4 sm:grid sm:grid-cols-3 sm:items-start"
    ) do
      label(
        for: "excluded_days",
        class:
          "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
      ) { helpers.t(".excluded_days") }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        input(
          name: "punch[excluded_days]",
          id: "punch_excluded_days",
          type: "text",
          data: { pos_employee_target: "excluded_days" },
          class:
            "mort-form-text"
        )
      end
    end
  end

  def set_comment
    div(
      class: "my-4 sm:grid sm:grid-cols-3 sm:items-start"
    ) do
      label(
        for: "comment",
        class:
          "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
      ) { helpers.t(".comment") }
      div(class: "mt-2 sm:col-span-2 sm:mt-0") do
        input(
          name: "punch[comment]",
          id: "punch_comment",
          type: "text",
          data: { pos_employee_target: "comment" },
          class:
            "mort-form-text"
        )
      end
    end
  end

  def slider(action:, enabled:, reason:)
    klass = enabled ? "translate-x-5" : "translate-x-0"
    button(
      type: "button",
      data: {
        action: action,
        pos_employee_target: "#{reason}Button"
      },
      class: "bg-gray-200 aria-checked:bg-sky-600 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2",
      role: "switch",
      aria_checked: enabled ? "true" : "false"
    ) do
      span(class: "sr-only") { reason }
      # Enabled: "translate-x-5", Not Enabled: "translate-x-0"
      span(
        data: {
          pos_employee_target: "#{reason}Span"
        },
        aria_hidden: "true",
        class:
          "#{klass} pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
      )
    end
  end

  def set_options(reason:, label:, reasons:)
    div(class: "hidden", data: { pos_employee_target: "#{reason}Options" }) do
      div(class: "my-4 sm:grid sm:grid-cols-3 sm:items-start") do
        label(for: "punch_reason", class: "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5") { label }
        div(class: "mt-2 sm:col-span-2 sm:mt-0") do
          div(class: "flex sm:max-w-md") do
            fieldset(class: "mt-4") do
              legend(class: "sr-only") { "#{reason} reasons" }
              div(class: "space-y-2") do
                reasons.each do |r|
                  div(class: "flex items-center") do
                    input(
                      id: "#{reason}_punch_reason",
                      name: "punch[reason]",
                      type: "radio",
                      value: r,
                      # checked: "checked" if punch.state == r,
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
end
