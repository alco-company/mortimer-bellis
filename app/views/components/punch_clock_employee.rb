class PunchClockEmployee < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField
  include Phlex::Rails::Helpers::ButtonTag

  attr_accessor :employee, :tab

  def initialize(employee: nil, tab: "today")
    @employee = employee || false
    @tab = tab
  end

  def view_template
    div(class: "h-full w-full") do
      div(class: "sm:p-4 ") do
        case tab
        when "payroll"; show_payroll
        when "profile"; show_profile
        else; show_today
        end
      end
    end
  end

  def show_today
    today_punch_buttons
    todays_minutes

    h4(class: "m-4 text-gray-700 text-xl") { helpers.t(".todays_punches") }
    ul(class: "m-4") do
      employee.todays_punches.each do |punch|
        li(
          id: (helpers.dom_id punch),
          class: "flex items-center justify-between gap-x-6 py-5"
        ) do
          div(class: "min-w-0 w-full columns-2") do
            span { helpers.render_datetime_column(field: punch.punched_at, css: "") }
            span { helpers.render_text_column(field: punch.state, css: "text-right") }
          end
          div(class: "flex flex-none items-center gap-x-4") do
            helpers.render_contextmenu resource: punch, turbo_frame: helpers.dom_id(punch), alter: false
          end
        end
      end
    end
  end

  def show_payroll
    div(class: "p-4") do
      off_time_punch_buttons
    end
  end

  def today_punch_buttons
    div(class: "flex items-center justify-center w-full p-5 font-medium rtl:text-right text-gray-500 gap-3") do
      punch_in
      punch_break
      punch_out
    end
  end

  def off_time_punch_buttons
    form do
      div(class: "mx-4 my-2 space-y-12 sm:space-y-16") do
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            helpers.t(".manuel_entry")
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            helpers.t(".manuel_entry_description")
          end
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
                class:
                  "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
              )
            end
          end
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
                class:
                  "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
              )
            end
          end
          div(
            class: "my-2 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
          ) do
            whitespace
            label(
              for: "reason",
              class:
                "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            ) { helpers.t("type_of_registration") }
            div(class: "mt-2 sm:col-span-2 sm:mt-0") do
              div(
                class:
                  "flex focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
              ) do
                whitespace
                div(class: "grid grid-flow-row-dense grid-cols-3 grid-rows-2 gap-4") do
                  div() { helpers.t(".work") }
                  div() { helpers.t(".sick") }
                  div() { helpers.t(".free") }
                  button(
                      type: "button",
                      class:
                        "bg-gray-200 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
                      role: "switch",
                      aria_checked: "false"
                    ) do
                      whitespace
                      span(class: "sr-only") { "work" }
                      whitespace
                      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
                      whitespace
                      span(
                        aria_hidden: "true",
                        class:
                          "translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                      )
                    end

                  button(
                      type: "button",
                      class:
                        "bg-gray-200 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
                      role: "switch",
                      aria_checked: "false"
                    ) do
                      whitespace
                      span(class: "sr-only") { "work" }
                      whitespace
                      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
                      whitespace
                      span(
                        aria_hidden: "true",
                        class:
                          "translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                      )
                    end

                  button(
                      type: "button",
                      class:
                        "bg-gray-200 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
                      role: "switch",
                      aria_checked: "false"
                    ) do
                      whitespace
                      span(class: "sr-only") { "work" }
                      whitespace
                      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
                      whitespace
                      span(
                        aria_hidden: "true",
                        class:
                          "translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                      )
                    end

                end

                
              end
            end
          end
          div(
            class: "my-2 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
          ) do
            whitespace
            label(
              for: "reason",
              class:
                "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            ) { helpers.t("free_reason") }
            div(class: "mt-2 sm:col-span-2 sm:mt-0") do
              div(
                class:
                  "flex focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
              ) do
                whitespace
                fieldset(class: "mt-4", data: { _target: "free_reasons"}) do
                  legend(class: "sr-only") { "Free reasons" }
                  div(class: "space-y-4") do
                    %w[rr_free senior_free unpaid_free maternity_free leave_free].each do |reason|
                      div(class: "flex items-center") do
                        whitespace
                        input(
                          id: reason,
                          name: "punch[reason]",
                          type: "radio",
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
          div(
            class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
          ) do
            whitespace
            label(
              for: "reason",
              class:
                "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            ) { helpers.t("sick_reason") }
            div(class: "mt-2 sm:col-span-2 sm:mt-0") do
              div(
                class:
                  "flex focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
              ) do
                whitespace
                fieldset(class: "mt-4", data: { _target: "sick_reasons"}) do
                  legend(class: "sr-only") { "Sick reasons" }
                  div(class: "space-y-4") do
                    %w[iam_sick child_sick nursing_sick lost_work_sick p56_sick].each do |reason|
                      div(class: "flex items-center") do
                        whitespace
                        input(
                          id: reason,
                          name: "punch[reason]",
                          type: "radio",
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
            "inline-flex justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        ) { helpers.t("save") }
      end
    end
  end

  def todays_minutes
    div(class: "flex items-center justify-center w-full p-5 font-medium rtl:text-right text-gray-500 gap-3") do
      counters = employee.minutes_today_up_to_now
      say "counters: #{counters}"
      render Stats.new title: helpers.t(".stats_title"), stats: [
        { title: helpers.t(".worktime"), value: helpers.display_hours_minutes(counters[:work]) },
        { title: helpers.t(".breaks"), value: helpers.display_hours_minutes(counters[:break]) }
    ]
    end if employee
  end

  def punch_in
    return if employee.in?
    button_tag helpers.t(".in"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
    form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "inform", method: :post do
      hidden_field :employee, :api_key, value: employee.access_token
      hidden_field :employee, :state, value: :in
      hidden_field :employee, :id, value: employee.id
    end
  end

  def punch_break
    return unless employee.in?
    button_tag helpers.t(".break"), type: "submit", form: "breakform", class: "bg-yellow-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
    form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "breakform", method: :post do
      hidden_field :employee, :api_key, value: employee.access_token
      hidden_field :employee, :state, value: :break
      hidden_field :employee, :id, value: employee.id
    end
  end

  def punch_out
    return unless employee.in?
    button_tag helpers.t(".out"), type: "submit", form: "outform", class: "bg-red-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
    form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "outform", method: :post do
      hidden_field :employee, :api_key, value: employee.access_token
      hidden_field :employee, :state, value: :out
      hidden_field :employee, :id, value: employee.id
    end
  end

  def punch_free
    button_tag helpers.t(".free"), type: "submit", form: "manualform", class: "bg-lime-300 text-white block rounded-md px-3 py-2 text-xl font-medium"
  end

  def punch_sick
    button_tag helpers.t(".sick"), type: "submit", form: "manualform", class: "bg-cyan-600 text-white block rounded-md px-3 py-2 text-xl font-medium"
  end

  def punch_manual_time
    button_tag helpers.t(".manual"), type: "submit", form: "manualform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
  end

  def show_profile
    form do
      div(class: "mx-4 my-2 space-y-12 sm:space-y-16") do
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            "Profile"
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            "This information will be displayed publicly so be careful what you share."
          end
          div(
            class:
              "mt-10 space-y-8 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
          ) do
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "name",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t(".name") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                div(
                  class:
                    "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                ) do
                  whitespace
                  input(
                    name: "name",
                    id: "name",
                    autocomplete: "name",
                    class:
                      "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                    placeholder: "janesmith"
                  )
                end
              end
            end
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "description",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t(".description") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                whitespace
                textarea(
                  id: "description",
                  name: "description",
                  rows: "3",
                  class:
                    "block w-full max-w-2xl rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                )
                p(class: "mt-3 text-sm leading-6 text-gray-600") do
                  "Write a few sentences about yourself."
                end
              end
            end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-center sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "photo",
            #     class: "block text-sm font-medium leading-6 text-gray-900"
            #   ) { "Photo" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     div(class: "flex items-center gap-x-3") do
            #       whitespace
            #       whitespace
            #       button(
            #         type: "button",
            #         class:
            #           "rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            #       ) { "Change" }
            #     end
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "cover-photo",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "Cover photo" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     div(
            #       class:
            #         "flex max-w-2xl justify-center rounded-lg border border-dashed border-gray-900/25 px-6 py-10"
            #     ) do
            #       div(class: "text-center") do
            #         whitespace
            #         div(class: "mt-4 flex text-sm leading-6 text-gray-600") do
            #           whitespace
            #           label(
            #             for: "file-upload",
            #             class:
            #               "relative cursor-pointer rounded-md bg-white font-semibold text-indigo-600 focus-within:outline-none focus-within:ring-2 focus-within:ring-indigo-600 focus-within:ring-offset-2 hover:text-indigo-500"
            #           ) do
            #             whitespace
            #             span { "Upload a file" }
            #             whitespace
            #             input(
            #               id: "file-upload",
            #               name: "file-upload",
            #               type: "file",
            #               class: "sr-only"
            #             )
            #             whitespace
            #           end
            #           p(class: "pl-1") { "or drag and drop" }
            #         end
            #         p(class: "text-xs leading-5 text-gray-600") do
            #           "PNG, JPG, GIF up to 10MB"
            #         end
            #       end
            #     end
            #   end
            # end
          end
        end
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            "Personal Information"
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            "Use a permanent address where you can receive mail."
          end
          div(
            class:
              "mt-10 space-y-8 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
          ) do
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "first-name",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "First name" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "first-name",
            #       id: "first-name",
            #       autocomplete: "given-name",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "last-name",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "Last name" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "last-name",
            #       id: "last-name",
            #       autocomplete: "family-name",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "email",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { "Email address" }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                whitespace
                input(
                  id: "email",
                  name: "email",
                  type: "email",
                  autocomplete: "email",
                  class:
                    "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-md sm:text-sm sm:leading-6"
                )
              end
            end
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "cell_phone",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t("cell_phone") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                whitespace
                input(
                  name: "cell_phone",
                  id: "cell_phone",
                  autocomplete: "cell_phone",
                  class:
                    "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xl sm:text-sm sm:leading-6"
                )
              end
            end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "city",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "City" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "city",
            #       id: "city",
            #       autocomplete: "address-level2",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "region",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "State / Province" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "region",
            #       id: "region",
            #       autocomplete: "address-level1",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "postal-code",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "ZIP / Postal code" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "postal-code",
            #       id: "postal-code",
            #       autocomplete: "postal-code",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
          end
        end
        # div do
        #   h2(class: "text-base font-semibold leading-7 text-gray-900") do
        #     "Notifications"
        #   end
        #   p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
        #     "We'll always let you know about important changes, but you pick what else you want to hear about."
        #   end
        #   div(
        #     class:
        #       "mt-10 space-y-10 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
        #   ) do
        #     fieldset do
        #       legend(class: "sr-only") { "By Email" }
        #       div(class: "sm:grid sm:grid-cols-3 sm:gap-4 sm:py-6") do
        #         div(
        #           class: "text-sm font-semibold leading-6 text-gray-900",
        #           aria_hidden: "true"
        #         ) { "By Email" }
        #         div(class: "mt-4 sm:col-span-2 sm:mt-0") do
        #           div(class: "max-w-lg space-y-6") do
        #             div(class: "relative flex gap-x-3") do
        #               div(class: "flex h-6 items-center") do
        #                 whitespace
        #                 input(
        #                   id: "comments",
        #                   name: "comments",
        #                   type: "checkbox",
        #                   class:
        #                     "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #               end
        #               div(class: "text-sm leading-6") do
        #                 whitespace
        #                 label(
        #                   for: "comments",
        #                   class: "font-medium text-gray-900"
        #                 ) { "Comments" }
        #                 p(class: "mt-1 text-gray-600") do
        #                   "Get notified when someones posts a comment on a posting."
        #                 end
        #               end
        #             end
        #             div(class: "relative flex gap-x-3") do
        #               div(class: "flex h-6 items-center") do
        #                 whitespace
        #                 input(
        #                   id: "candidates",
        #                   name: "candidates",
        #                   type: "checkbox",
        #                   class:
        #                     "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #               end
        #               div(class: "text-sm leading-6") do
        #                 whitespace
        #                 label(
        #                   for: "candidates",
        #                   class: "font-medium text-gray-900"
        #                 ) { "Candidates" }
        #                 p(class: "mt-1 text-gray-600") do
        #                   "Get notified when a candidate applies for a job."
        #                 end
        #               end
        #             end
        #             div(class: "relative flex gap-x-3") do
        #               div(class: "flex h-6 items-center") do
        #                 whitespace
        #                 input(
        #                   id: "offers",
        #                   name: "offers",
        #                   type: "checkbox",
        #                   class:
        #                     "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #               end
        #               div(class: "text-sm leading-6") do
        #                 whitespace
        #                 label(
        #                   for: "offers",
        #                   class: "font-medium text-gray-900"
        #                 ) { "Offers" }
        #                 p(class: "mt-1 text-gray-600") do
        #                   "Get notified when a candidate accepts or rejects an offer."
        #                 end
        #               end
        #             end
        #           end
        #         end
        #       end
        #     end
        #     fieldset do
        #       legend(class: "sr-only") { "Push Notifications" }
        #       div(
        #         class:
        #           "sm:grid sm:grid-cols-3 sm:items-baseline sm:gap-4 sm:py-6"
        #       ) do
        #         div(
        #           class: "text-sm font-semibold leading-6 text-gray-900",
        #           aria_hidden: "true"
        #         ) { "Push Notifications" }
        #         div(class: "mt-1 sm:col-span-2 sm:mt-0") do
        #           div(class: "max-w-lg") do
        #             p(class: "text-sm leading-6 text-gray-600") do
        #               "These are delivered via SMS to your mobile phone."
        #             end
        #             div(class: "mt-6 space-y-6") do
        #               div(class: "flex items-center gap-x-3") do
        #                 whitespace
        #                 input(
        #                   id: "push-everything",
        #                   name: "push-notifications",
        #                   type: "radio",
        #                   class:
        #                     "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #                 whitespace
        #                 label(
        #                   for: "push-everything",
        #                   class:
        #                     "block text-sm font-medium leading-6 text-gray-900"
        #                 ) { "Everything" }
        #               end
        #               div(class: "flex items-center gap-x-3") do
        #                 whitespace
        #                 input(
        #                   id: "push-email",
        #                   name: "push-notifications",
        #                   type: "radio",
        #                   class:
        #                     "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #                 whitespace
        #                 label(
        #                   for: "push-email",
        #                   class:
        #                     "block text-sm font-medium leading-6 text-gray-900"
        #                 ) { "Same as email" }
        #               end
        #               div(class: "flex items-center gap-x-3") do
        #                 whitespace
        #                 input(
        #                   id: "push-nothing",
        #                   name: "push-notifications",
        #                   type: "radio",
        #                   class:
        #                     "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #                 whitespace
        #                 label(
        #                   for: "push-nothing",
        #                   class:
        #                     "block text-sm font-medium leading-6 text-gray-900"
        #                 ) { "No push notifications" }
        #               end
        #             end
        #           end
        #         end
        #       end
        #     end
        #   end
        # end
      end
      div(class: "mt-6 flex items-center justify-end gap-x-6") do
        whitespace
        button(
          type: "button",
          class: "text-sm font-semibold leading-6 text-gray-900"
        ) { "Cancel" }
        whitespace
        button(
          type: "submit",
          class:
            "inline-flex justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        ) { "Save" }
      end
    end
  end

  def show_today_old
    div(class: "w-full") do
      h2(class: "text-gray-700 text-xl") { helpers.t(".todays_punches") }
      # div( class: "mb-4 text-gray-700 text-xl") { helpers.t(".for_employee", name: employee.name) }
      div(class: "font-mono") do
        ul do
          employee.todays_punches.each do |punch|
            li(
              id: (helpers.dom_id punch),
              class: "flex items-center justify-between gap-x-6 py-5"
            ) do
              div(class: "min-w-0 w-full columns-2 text-gray-700 text-xl") do
                span { helpers.render_datetime_column(field: punch.punched_at, css: "") }
                span { helpers.render_text_column(field: punch.state, css: "text-right") }
              end
              div(class: "flex flex-none items-center gap-x-4") do
                helpers.render_contextmenu resource: punch
              end
            end
          end
        end
      end
    end
  end
end
