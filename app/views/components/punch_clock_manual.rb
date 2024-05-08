class PunchClockManual < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :employee

  def initialize(employee: nil)
    @employee = employee || false
  end

  def view_template(&block)
    form_with url: helpers.pos_employee_url(api_key: employee.access_token), method: :post do
      div(class: "mx-4 my-2 space-y-12 sm:space-y-16") do
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            helpers.t(".manuel_entry")
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            helpers.t(".manuel_entry_description")
          end
          # set the type of registration
          div(
            class: "my-2 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
          ) do
            whitespace
            label(
              for: "reason",
              class:
                "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            ) { helpers.t(".type_of_registration") }
            div(class: "mt-2 sm:col-span-2 sm:mt-0") do
              div(
                class:
                  "flex sm:max-w-md"
              ) do
                whitespace
                div(class: "grid grid-flow-row-dense grid-cols-3 grid-rows-2 gap-4") do
                  div() { helpers.t(".work") }
                  div() { helpers.t(".sick") }
                  div() { helpers.t(".free") }
                  button(
                      type: "button",
                      data: { 
                        action: "click->pos-employee#toggleWork",
                        pos_employee_target: "workButton"
                      },
                      class: "bg-gray-200 aria-checked:bg-sky-600 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
                      role: "switch",
                      aria_checked: "true"
                    ) do
                      whitespace
                      span(class: "sr-only") { "work" }
                      whitespace
                      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
                      whitespace
                      span(
                        data: { 
                          pos_employee_target: "workSpan"
                        },
                        aria_hidden: "true",
                        class:
                          "translate-x-5 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                      )
                    end
                  input(
                    id: 'in',
                    name: "punch[reason]",
                    type: "radio",
                    data: { 
                      pos_employee_target: "workReason"
                    },
                    value: 'in',
                    checked: "checked",
                    class:
                      "hidden"
                  )

                  button(
                      type: "button",
                      data: { 
                        action: "click->pos-employee#toggleSick",
                        pos_employee_target: "sickButton"
                      },
                      class: "bg-gray-200 aria-checked:bg-sky-600 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
                      role: "switch",
                      aria_checked: "false"
                    ) do
                      whitespace
                      span(class: "sr-only") { "sick" }
                      whitespace
                      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
                      whitespace
                      span(
                        data: { 
                          pos_employee_target: "sickSpan"
                        },
                        aria_hidden: "true",
                        class:
                          "translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                      )
                    end

                  button(
                      type: "button",
                      data: { 
                        action: "click->pos-employee#toggleFree",
                        pos_employee_target: "freeButton"
                      },
                      class: "bg-gray-200 aria-checked:bg-sky-600 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
                      role: "switch",
                      aria_checked: "false"
                    ) do
                      whitespace
                      span(class: "sr-only") { "free" }
                      whitespace
                      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
                      whitespace
                      span(
                        data: {
                          pos_employee_target: "freeSpan"
                        },
                        aria_hidden: "true",
                        class:
                          "translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                      )
                    end
                end
              end
            end
          end
          # set the time slot from_at
          div(
            class: "my-2 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
          ) do
            whitespace
            label(
              for: "from_at",
              class:
                "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            ) { helpers.t("from_at") }
            div(class: "mt-2 sm:col-span-2 sm:mt-0") do
              whitespace
              input(
                name: "punch[from_at]",
                id: "from_at",
                type: "datetime-local",
                data: { pos_employee_target: "fromAt" },
                autofocus: true,
                class:
                  "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
              )
            end
          end

          # set the time slot to_at
          div(
            class: "my-2 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
          ) do
            whitespace
            label(
              for: "to_at",
              class:
                "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            ) { helpers.t("to_at") }
            div(class: "mt-2 sm:col-span-2 sm:mt-0") do
              whitespace
              input(
                name: "punch[to_at]",
                id: "from_at",
                type: "datetime-local",
                data: { pos_employee_target: "toAt" },
                class:
                  "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
              )
            end
          end

          # set the free Options
          div(class: "hidden", data: { pos_employee_target: "freeOptions" }) do
            div(
              class: "my-2 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6 "
            ) do
              whitespace
              label(
                for: "reason",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t(".free_reason") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                div(
                  class:
                    "flex sm:max-w-md"
                ) do
                  whitespace
                  fieldset(class: "mt-4") do
                    legend(class: "sr-only") { "Free reasons" }
                    div(class: "space-y-4") do
                      %w[rr_free senior_free unpaid_free maternity_free leave_free].each do |reason|
                        div(class: "flex items-center") do
                          whitespace
                          input(
                            id: reason,
                            name: "punch[reason]",
                            type: "radio",
                            value: reason,
                            # checked: "checked" if punch.state == reason,
                            class:
                              "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
                          )
                          whitespace
                          label(
                            for: reason,
                            class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
                          ) { helpers.t(".#{reason}") }
                        end
                      end
                    end
                  end
                end
              end
            end
          end

          # set the sick Options
          div(class: "hidden", data: { pos_employee_target: "sickOptions" }) do
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6 "
            ) do
              whitespace
              label(
                for: "reason",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t(".sick_reason") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                div(
                  class:
                    "flex sm:max-w-md"
                ) do
                  whitespace
                  fieldset(class: "mt-4") do
                    legend(class: "sr-only") { "Sick reasons" }
                    div(class: "space-y-4") do
                      %w[iam_sick child_sick nursing_sick lost_work_sick p56_sick].each do |reason|
                        div(class: "flex items-center") do
                          whitespace
                          input(
                            id: reason,
                            name: "punch[reason]",
                            type: "radio",
                            value: reason,
                            # checked: "checked" if punch.state == reason,
                            class:
                              "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
                          )
                          whitespace
                          label(
                            for: reason,
                            class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
                          ) { helpers.t(".#{reason}") }
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
      action_buttons
    end
  end

  def action_buttons
    div(class: "mt-6 mb-24 sm:mb-12 flex items-center justify-start gap-x-2") do
      whitespace
      button(
        type: "button",
        class: "text-sm font-semibold leading-6 text-gray-900"
      ) { helpers.t("cancel") }
      whitespace
      button(
        type: "submit",
        class:
          "mort-btn-primary"
      ) { helpers.t("save") }
    end
  end

  def punch_in
    return if employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t("+"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
      form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "inform", method: :post do
        hidden_field :employee, :api_key, value: employee.access_token
        hidden_field :employee, :state, value: :in
        hidden_field :employee, :id, value: employee.id
      end
    end
  end
end
